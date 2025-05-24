package main

import (
	"log"
	"net/http"

	"github.com/gorilla/mux"
	"github.com/savak1990/test-dynamodb-app/app/aws"
	"github.com/savak1990/test-dynamodb-app/app/config"
	"github.com/savak1990/test-dynamodb-app/app/handler"
	"github.com/savak1990/test-dynamodb-app/app/repo"
	"github.com/savak1990/test-dynamodb-app/app/service"
)

func main() {
	appCfg := config.LoadConfig()
	log.Printf("Loaded config: region=%s, profile=%s\n", appCfg.AWSRegion, appCfg.AWSProfile)

	awsCfg := aws.LoadAWSConfig(appCfg.AWSRegion, appCfg.AWSProfile)
	log.Printf("AWS Debug Info: Region=%s\n", awsCfg.Region)

	dbClient := aws.GetDynamoDbClient(awsCfg.Region)
	log.Printf("DynamoDB client info: EndpointResolver=%T\n", dbClient.Options().BaseEndpoint)

	wishRepo := repo.NewDynamoDbWishRepository(dbClient, "AhorroWishlist")
	wishService := service.NewWishService(wishRepo)
	wishHandler := handler.NewWishHandler(wishService)

	router := mux.NewRouter()
	router.Use(mux.CORSMethodMiddleware(router))
	router.HandleFunc("/wishes/{userId}", wishHandler.CreateWish).Methods("POST")
	router.HandleFunc("/wishes/{userId}/{wishId}", wishHandler.GetWishByWishId).Methods("GET")
	router.HandleFunc("/wishes/{userId}", wishHandler.GetWishList).Methods("GET")

	log.Printf("Starting server on port 8080")
	if err := http.ListenAndServe(":8080", router); err != nil {
		log.Fatalf("Could not start server: %s\n", err)
	}
}
