package repo

import (
	"context"
	"log"

	"github.com/aws/aws-sdk-go-v2/service/dynamodb"
	m "github.com/savak1990/test-dynamodb-app/app/models"
)

type DynamoDbWishRepository struct {
	client    DynamoDbClient
	tableName string
}

func NewDynamoDbWishRepository(client DynamoDbClient, tableName string) *DynamoDbWishRepository {
	validateTable(context.TODO(), client, tableName)
	return &DynamoDbWishRepository{
		client:    client,
		tableName: tableName,
	}
}

func validateTable(ctx context.Context, client DynamoDbClient, tableName string) {
	_, err := client.DescribeTable(ctx, &dynamodb.DescribeTableInput{
		TableName: &tableName,
	})
	if err != nil {
		panic("Failed to describe DynamoDB table: " + err.Error())
	}
	log.Printf("DynamoDB table %s is valid\n", tableName)
}

func (r *DynamoDbWishRepository) CreateWish(ctx context.Context, wish m.Wish) error {

	item, err := dynamoDbMarshalMapFunc(wish)
	if err != nil {
		return err
	}

	_, err = r.client.PutItem(ctx, &dynamodb.PutItemInput{
		TableName: &r.tableName,
		Item:      item,
	})

	return err
}
