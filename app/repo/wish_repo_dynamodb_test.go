package repo

import (
	"context"
	"errors"
	"testing"

	"github.com/aws/aws-sdk-go-v2/service/dynamodb"
	"github.com/aws/aws-sdk-go-v2/service/dynamodb/types"
	m "github.com/savak1990/test-dynamodb-app/app/models"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"
)

func mockErrorDynamoDbMarshalMapFunc(input interface{}) (map[string]types.AttributeValue, error) {
	return nil, errors.New("mock marshal error")
}

func TestCreateWish(t *testing.T) {
	ctx := context.TODO()

	mockClient := NewMockDynamoDBClient()
	mockDescribeTableFn := mockClient.On("DescribeTable", mock.Anything, mock.Anything).Return(&dynamodb.DescribeTableOutput{}, nil)
	defer mockDescribeTableFn.Unset()

	repo := NewDynamoDbWishRepository(mockClient, "test-table")

	t.Run("Success", func(t *testing.T) {
		mockPutItem := mockClient.On("PutItem", mock.Anything, mock.Anything).Return(&dynamodb.PutItemOutput{}, nil)
		defer mockPutItem.Unset()

		wish := m.Wish{
			UserId:   "1",
			Title:    "mockTitle",
			Priority: 1,
		}

		err := repo.CreateWish(ctx, wish)

		assert.NoError(t, err)
	})

	t.Run("MarshalMapFailure", func(t *testing.T) {
		mockPutItem := mockClient.On("PutItem", mock.Anything, mock.Anything).Return(&dynamodb.PutItemOutput{}, nil)
		defer mockPutItem.Unset()

		originalMarshalMap := dynamoDbMarshalMapFunc
		dynamoDbMarshalMapFunc = mockErrorDynamoDbMarshalMapFunc
		defer func() { dynamoDbMarshalMapFunc = originalMarshalMap }()

		invalidWish := m.Wish{
			UserId:  "1",
			Content: "Test Wish",
		}

		err := repo.CreateWish(ctx, invalidWish)

		assert.Error(t, err)
		assert.Contains(t, err.Error(), "mock marshal error")
	})

	t.Run("PutItemFailure", func(t *testing.T) {
		mockPutItem := mockClient.On("PutItem", mock.Anything, mock.Anything).Return(nil, errors.New("failed to put item"))
		defer mockPutItem.Unset()

		wish := m.Wish{
			UserId:  "2",
			Content: "Another Test Wish",
		}

		err := repo.CreateWish(ctx, wish)

		assert.Error(t, err)
		assert.Equal(t, "failed to put item", err.Error())
	})
}
