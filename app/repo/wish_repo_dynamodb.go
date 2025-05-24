package repo

import (
	"context"
	"log"

	"github.com/aws/aws-sdk-go-v2/service/dynamodb"
	"github.com/aws/aws-sdk-go-v2/service/dynamodb/types"
	"github.com/aws/aws-sdk-go/aws"
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

func (r *DynamoDbWishRepository) GetWishByWishId(ctx context.Context, userId string, wishId string) (*m.Wish, error) {
	result, err := r.client.GetItem(ctx, &dynamodb.GetItemInput{
		TableName: &r.tableName,
		Key: map[string]types.AttributeValue{
			"userId": &types.AttributeValueMemberS{Value: userId},
			"wishId": &types.AttributeValueMemberS{Value: wishId},
		},
	})

	if err != nil {
		return nil, err
	}

	if result.Item == nil {
		return nil, nil
	}

	var wish m.Wish
	err = dynamoDbUnmarshalMapFunc(result.Item, &wish)
	if err != nil {
		return nil, err
	}

	return &wish, nil
}

func (r *DynamoDbWishRepository) GetWishList(ctx context.Context, userId string) ([]m.Wish, error) {
	result, err := r.client.Query(ctx, &dynamodb.QueryInput{
		TableName:              &r.tableName,
		KeyConditionExpression: aws.String("userId = :userId"),
		ExpressionAttributeValues: map[string]types.AttributeValue{
			":userId": &types.AttributeValueMemberS{Value: userId},
		},
	})

	if err != nil {
		return nil, err
	}

	var wishes []m.Wish
	err = dynamoDbUnmarshalListOfMapsFunc(result.Items, &wishes)
	if err != nil {
		return nil, err
	}

	return wishes, nil
}
