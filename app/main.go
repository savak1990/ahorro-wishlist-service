package main

import (
	"net/http"

	"github.com/gorilla/mux"
	"github.com/savak1990/test-dynamodb-app/app/aws"
	"github.com/savak1990/test-dynamodb-app/app/config"
	"github.com/savak1990/test-dynamodb-app/app/handler"
	"github.com/savak1990/test-dynamodb-app/app/repo"
	"github.com/savak1990/test-dynamodb-app/app/service"
	log "github.com/sirupsen/logrus"
)

func init() {
	log.SetFormatter(&log.TextFormatter{
		FullTimestamp: true,
	})
	log.SetLevel(log.InfoLevel)
}

func main() {
	appCfg := config.LoadConfig()
	log.Infof("Loaded config: region=%s, profile=%s\n", appCfg.AWSRegion, appCfg.AWSProfile)

	awsCfg := aws.LoadAWSConfig(appCfg.AWSRegion, appCfg.AWSProfile)
	log.Infof("AWS Debug Info: Region=%s\n", awsCfg.Region)

	dbClient := aws.GetDynamoDbClient(awsCfg)
	log.Infof("DynamoDB client info: EndpointResolver=%T\n", dbClient.Options().BaseEndpoint)

	wishRepo := repo.NewDynamoDbWishRepository(dbClient, appCfg.TableName)
	wishService := service.NewWishService(wishRepo)
	wishHandler := handler.NewWishHandler(wishService)

	commonHandler := handler.NewCommonHandlerImpl()

	router := mux.NewRouter()
	router.Use(mux.CORSMethodMiddleware(router))

	router.HandleFunc("/wishes/{userId}/{wishId}", wishHandler.GetWishByWishId).Methods("GET")
	router.HandleFunc("/wishes/{userId}", wishHandler.GetWishList).Methods("GET")
	router.HandleFunc("/wishes/{userId}", wishHandler.CreateWish).Methods("POST")
	router.HandleFunc("/wishes/{userId}/{wishId}", wishHandler.UpdateWish).Methods("PUT")
	router.HandleFunc("/wishes/{userId}/{wishId}", wishHandler.DeleteWish).Methods("DELETE")

	router.HandleFunc("/health", commonHandler.HandleHealth).Methods("GET")
	router.HandleFunc("/info", commonHandler.HandleInfo).Methods("GET")

	log.Printf("Starting server on port 8080")
	if err := http.ListenAndServe(":8080", router); err != nil {
		log.Fatalf("Could not start server: %s\n", err)
	}
}
