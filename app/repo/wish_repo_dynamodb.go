package repo

import (
	"context"
	"fmt"

	"github.com/aws/aws-sdk-go-v2/service/dynamodb"
	"github.com/aws/aws-sdk-go-v2/service/dynamodb/types"
	"github.com/aws/aws-sdk-go/aws"
	m "github.com/savak1990/test-dynamodb-app/app/models"
	log "github.com/sirupsen/logrus"
)

type DynamoDbWishRepository struct {
	client    DynamoDbClient
	tableName string
}

func NewDynamoDbWishRepository(client DynamoDbClient, tableName string) *DynamoDbWishRepository {

	log.WithField("tableName", tableName).Info("Initializing DynamoDB Wish Repository")

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
	log.Infof("DynamoDB table %s is valid\n", tableName)
}

func (r *DynamoDbWishRepository) CreateWish(ctx context.Context, wish m.Wish) error {

	log.WithField("wish", wish).Debug("Repo: Creating wish")

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

	log.WithField("userId", userId).WithField("wishId", wishId).Debug("Repo: Getting wish by wishId")

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

func (r *DynamoDbWishRepository) GetUserWishes(ctx context.Context, userId string, lsi string, scanForward bool) ([]m.Wish, error) {

	log.WithField("userId", userId).WithField("scanForward", scanForward).Debug("Repo: Getting wish list")

	var sortIndex *string
	if lsi != "" {
		sortIndex = aws.String(lsi)
	}

	result, err := r.client.Query(ctx, &dynamodb.QueryInput{
		TableName:              &r.tableName,
		IndexName:              sortIndex,
		ScanIndexForward:       aws.Bool(scanForward),
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

func (r *DynamoDbWishRepository) UpdateWish(ctx context.Context, wish m.Wish) (*m.Wish, error) {
	log.WithField("wish", wish).Debug("Repo: Updating wish")

	_, err := r.client.UpdateItem(ctx, &dynamodb.UpdateItemInput{
		TableName: &r.tableName,
		Key: map[string]types.AttributeValue{
			"userId": &types.AttributeValueMemberS{Value: wish.UserId},
			"wishId": &types.AttributeValueMemberS{Value: wish.WishId},
		},
		ExpressionAttributeNames: map[string]string{
			"#title":    "title",
			"#content":  "content",
			"#priority": "priority",
			"#updated":  "updated",
			"#due":      "due",
		},
		ExpressionAttributeValues: map[string]types.AttributeValue{
			":title":    &types.AttributeValueMemberS{Value: wish.Title},
			":content":  &types.AttributeValueMemberS{Value: wish.Content},
			":priority": &types.AttributeValueMemberN{Value: fmt.Sprintf("%d", wish.Priority)},
			":updated":  &types.AttributeValueMemberS{Value: wish.Updated},
			":due":      &types.AttributeValueMemberS{Value: wish.Due},
		},
		UpdateExpression: aws.String("SET #title = :title, #content = :content, #priority = :priority, #updated = :updated, #due = :due"),
		ReturnValues:     types.ReturnValueAllNew,
	})
	if err != nil {
		return nil, err
	}

	// Fetch the updated wish and return it
	return r.GetWishByWishId(ctx, wish.UserId, wish.WishId)
}

func (r *DynamoDbWishRepository) DeleteWish(ctx context.Context, userId string, wishId string) error {
	log.WithField("userId", userId).WithField("wishId", wishId).Debug("Repo: Deleting wish")

	_, err := r.client.DeleteItem(ctx, &dynamodb.DeleteItemInput{
		TableName: &r.tableName,
		Key: map[string]types.AttributeValue{
			"userId": &types.AttributeValueMemberS{Value: userId},
			"wishId": &types.AttributeValueMemberS{Value: wishId},
		},
	})

	return err
}

func (r *DynamoDbWishRepository) GetAllWishes(ctx context.Context, gsi string, scanForward bool) ([]m.Wish, error) {

	log.WithField("scanForward", scanForward).Debug("Repo: Getting all wishes sorted by priority")

	result, err := r.client.Query(ctx, &dynamodb.QueryInput{
		TableName:              &r.tableName,
		IndexName:              aws.String(gsi),
		ScanIndexForward:       aws.Bool(scanForward),
		KeyConditionExpression: aws.String("#all = :all"),
		ExpressionAttributeNames: map[string]string{
			"#all": "all",
		},
		ExpressionAttributeValues: map[string]types.AttributeValue{
			":all": &types.AttributeValueMemberS{Value: "all"},
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

func (r *DynamoDbWishRepository) GetWishesSortedByPriority(ctx context.Context, userId string, scanForward bool) ([]m.Wish, error) {

	log.WithField("userId", userId).WithField("scanForward", scanForward).Debug("Repo: Getting wishes sorted by priority")

	result, err := r.client.Query(ctx, &dynamodb.QueryInput{
		TableName:              &r.tableName,
		IndexName:              aws.String(r.lsiPriorityIndexName()),
		ScanIndexForward:       aws.Bool(scanForward),
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

func (r *DynamoDbWishRepository) GetWishesSortedByCreatedAt(ctx context.Context, userId string, scanForward bool) ([]m.Wish, error) {

	log.WithField("userId", userId).WithField("scanForward", scanForward).Debug("Repo: Getting wishes sorted by created at")

	result, err := r.client.Query(ctx, &dynamodb.QueryInput{
		TableName:              &r.tableName,
		IndexName:              aws.String(r.lsiCreatedIndexName()),
		ScanIndexForward:       aws.Bool(scanForward),
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

func (r *DynamoDbWishRepository) GetGlobalSortIndexName(sortBy string) string {
	switch sortBy {
	case "priority":
		return r.gsiAllPriorityIndexName()
	case "created":
		return r.gsiAllCreatedIndexName()
	case "due":
		return r.gsiAllDueIndexName()
	default:
		return ""
	}
}

func (r *DynamoDbWishRepository) GetLocalSortIndexName(sortBy string) string {
	switch sortBy {
	case "priority":
		return r.lsiPriorityIndexName()
	case "created":
		return r.lsiCreatedIndexName()
	case "due":
		return r.lsiDueIndexName()
	default:
		return ""
	}
}

func (r *DynamoDbWishRepository) gsiAllCreatedIndexName() string {
	return fmt.Sprintf("%s-gsi-all-created", r.tableName)
}

func (r *DynamoDbWishRepository) gsiAllPriorityIndexName() string {
	return fmt.Sprintf("%s-gsi-all-priority", r.tableName)
}

func (r *DynamoDbWishRepository) gsiAllDueIndexName() string {
	return fmt.Sprintf("%s-gsi-all-due", r.tableName)
}

func (r *DynamoDbWishRepository) lsiCreatedIndexName() string {
	return fmt.Sprintf("%s-lsi-created", r.tableName)
}

func (r *DynamoDbWishRepository) lsiPriorityIndexName() string {
	return fmt.Sprintf("%s-lsi-priority", r.tableName)
}

func (r *DynamoDbWishRepository) lsiDueIndexName() string {
	return fmt.Sprintf("%s-lsi-due", r.tableName)
}

// Ensure DynamoDbWishRepository implements WishRepository interface
var _ WishRepository = (*DynamoDbWishRepository)(nil)
