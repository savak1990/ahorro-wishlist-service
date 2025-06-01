package main

import (
	"context"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"

	log "github.com/sirupsen/logrus"
)

func init() {
	log.SetFormatter(&log.TextFormatter{
		FullTimestamp: true,
	})
	log.SetLevel(log.InfoLevel)
}

func handler(ctx context.Context, event events.DynamoDBEvent) error {
	log.Infof("Received DynamoDB event: %v", event)
	for _, record := range event.Records {
		if record.EventName == "INSERT" {
			log.Infof("New item added: %s\n", record.Change.NewImage)
		} else if record.EventName == "MODIFY" {
			log.Infof("Item modified: %s\n", record.Change.NewImage)
		} else if record.EventName == "REMOVE" {
			log.Infof("Item removed: %s\n", record.Change.Keys)
		}
	}
	return nil
}

func main() {
	log.Info("Starting DynamoDB Stream Handler Lambda")
	lambda.Start(handler)
}
