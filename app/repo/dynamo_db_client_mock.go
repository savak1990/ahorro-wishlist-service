package repo

import (
	"context"

	"github.com/aws/aws-sdk-go-v2/service/dynamodb"
	"github.com/stretchr/testify/mock"
)

type MockDynamoDBClient struct {
	mock.Mock
}

func NewMockDynamoDBClient() *MockDynamoDBClient {
	return &MockDynamoDBClient{}
}

func (m *MockDynamoDBClient) DescribeTable(ctx context.Context,
	params *dynamodb.DescribeTableInput,
	optFns ...func(*dynamodb.Options)) (*dynamodb.DescribeTableOutput, error) {

	args := m.Called(ctx, params)
	var out *dynamodb.DescribeTableOutput
	if v := args.Get(0); v != nil {
		out = v.(*dynamodb.DescribeTableOutput)
	}
	return out, args.Error(1)
}

func (m *MockDynamoDBClient) PutItem(ctx context.Context,
	input *dynamodb.PutItemInput,
	optFns ...func(*dynamodb.Options)) (*dynamodb.PutItemOutput, error) {

	args := m.Called(ctx, input)
	var out *dynamodb.PutItemOutput
	if v := args.Get(0); v != nil {
		out = v.(*dynamodb.PutItemOutput)
	}
	return out, args.Error(1)
}

func (m *MockDynamoDBClient) GetItem(ctx context.Context,
	input *dynamodb.GetItemInput,
	optFns ...func(*dynamodb.Options)) (*dynamodb.GetItemOutput, error) {

	args := m.Called(ctx, input)
	var out *dynamodb.GetItemOutput
	if v := args.Get(0); v != nil {
		out = v.(*dynamodb.GetItemOutput)
	}
	return out, args.Error(1)
}

func (m *MockDynamoDBClient) Query(ctx context.Context,
	params *dynamodb.QueryInput,
	optFns ...func(*dynamodb.Options)) (*dynamodb.QueryOutput, error) {

	args := m.Called(ctx, params)
	var out *dynamodb.QueryOutput
	if v := args.Get(0); v != nil {
		out = v.(*dynamodb.QueryOutput)
	}
	return out, args.Error(1)
}
