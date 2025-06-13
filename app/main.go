package main

import (
	"context"
	"net/http"
	"os"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/awslabs/aws-lambda-go-api-proxy/core"
	"github.com/awslabs/aws-lambda-go-api-proxy/gorillamux"
	"github.com/gorilla/mux"
	"github.com/savak1990/test-dynamodb-app/app/aws"
	"github.com/savak1990/test-dynamodb-app/app/config"
	"github.com/savak1990/test-dynamodb-app/app/handler"
	"github.com/savak1990/test-dynamodb-app/app/repo"
	"github.com/savak1990/test-dynamodb-app/app/service"

	"encoding/json"

	log "github.com/sirupsen/logrus"
)

func init() {
	log.SetFormatter(&log.TextFormatter{
		FullTimestamp: true,
	})
	log.SetLevel(log.InfoLevel)
}

// Lambda handler for API Gateway
func lambdaHandler(adapter *gorillamux.GorillaMuxAdapter) func(ctx context.Context, event events.APIGatewayV2HTTPRequest) (events.APIGatewayV2HTTPResponse, error) {
	return func(ctx context.Context, event events.APIGatewayV2HTTPRequest) (events.APIGatewayV2HTTPResponse, error) {
		if reqBytes, err := json.MarshalIndent(event, "", "  "); err == nil {
			log.Info("API Gateway request:\n" + string(reqBytes))
		} else {
			log.WithError(err).Warn("Failed to marshal API Gateway request")
		}

		resp, err := adapter.ProxyWithContext(ctx, *core.NewSwitchableAPIGatewayRequestV2(&event))

		if respBytes, err := json.MarshalIndent(resp, "", "  "); err == nil {
			log.Info("API Gateway response:\n" + string(respBytes))
		} else {
			log.WithError(err).Warn("Failed to marshal API Gateway response")
		}

		return *resp.Version2(), err
	}
}

func main() {
	appCfg := config.LoadConfig()
	log.WithFields(log.Fields{
		"region":  appCfg.AWSRegion,
		"profile": appCfg.AWSProfile,
	}).Info("Loaded config")

	awsCfg := aws.LoadAWSConfig(appCfg.AWSRegion, appCfg.AWSProfile)
	log.WithField("region", awsCfg.Region).Info("AWS Debug Info")

	dbClient := aws.GetDynamoDbClient(awsCfg)
	log.WithField("endpointResolver", dbClient.Options().BaseEndpoint).Info("DynamoDB client info")

	wishRepo := repo.NewDynamoDbWishRepository(dbClient, appCfg.TableName)
	wishService := service.NewWishService(wishRepo)
	wishHandler := handler.NewWishHandler(wishService)

	commonHandler := handler.NewCommonHandlerImpl()

	router := mux.NewRouter()
	router.Use(mux.CORSMethodMiddleware(router))
	router.Use(handler.EnsureAwsRegionHeader(appCfg.AWSRegion))

	router.HandleFunc("/wishes/{userId}/{wishId}", wishHandler.GetWishByWishId).Methods("GET")
	router.HandleFunc("/wishes/{userId}", wishHandler.GetWishList).Methods("GET")
	router.HandleFunc("/wishes/{userId}", wishHandler.CreateWish).Methods("POST")
	router.HandleFunc("/wishes/{userId}/{wishId}", wishHandler.UpdateWish).Methods("PUT")
	router.HandleFunc("/wishes/{userId}/{wishId}", wishHandler.DeleteWish).Methods("DELETE")
	router.HandleFunc("/health", commonHandler.HandleHealth).Methods("GET")
	router.HandleFunc("/info", commonHandler.HandleInfo).Methods("GET")

	// Lambda/API Gateway integration: use the muxadapter if running in Lambda
	if os.Getenv("AWS_LAMBDA_FUNCTION_NAME") != "" || os.Getenv("_LAMBDA_SERVER_PORT") != "" {
		adapter := gorillamux.New(router)
		lambda.Start(lambdaHandler(adapter))
		return
	}

	// Local dev server
	log.Info("Starting server on port 8080")
	if err := http.ListenAndServe(":8080", router); err != nil {
		log.Fatalf("Could not start server: %s", err)
	}
}
