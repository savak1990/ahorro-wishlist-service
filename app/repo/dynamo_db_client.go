package repo

import (
	"context"

	"github.com/aws/aws-sdk-go-v2/service/dynamodb"
)

type DynamoDbClient interface {
	DescribeTable(ctx context.Context,
		params *dynamodb.DescribeTableInput,
		optFns ...func(*dynamodb.Options)) (*dynamodb.DescribeTableOutput, error)

	PutItem(ctx context.Context,
		input *dynamodb.PutItemInput,
		optFns ...func(*dynamodb.Options)) (*dynamodb.PutItemOutput, error)

	GetItem(ctx context.Context,
		input *dynamodb.GetItemInput,
		optFns ...func(*dynamodb.Options)) (*dynamodb.GetItemOutput, error)

	Query(ctx context.Context,
		params *dynamodb.QueryInput,
		optFns ...func(*dynamodb.Options)) (*dynamodb.QueryOutput, error)
}
