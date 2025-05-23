package service

import (
	"context"
	"errors"
	"testing"

	m "github.com/savak1990/test-dynamodb-app/app/models"
	"github.com/savak1990/test-dynamodb-app/app/repo"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"
)

func Test_CreateWish(t *testing.T) {
	ctx := context.TODO()
	mockRepo := repo.NewMockWishRepository()
	testWishService := NewWishService(mockRepo)

	t.Run("Success", func(t *testing.T) {
		createWishFunc := mockRepo.On("CreateWish", ctx, mock.Anything).Return(nil)
		defer createWishFunc.Unset()

		wish := m.Wish{
			ID:      "1",
			Content: "Test Wish",
		}
		err := testWishService.CreateWish(ctx, wish)

		assert.NoError(t, err)
		mockRepo.AssertExpectations(t)
	})

	t.Run("RepoReturnNil", func(t *testing.T) {
		mockCreateWishFunc := mockRepo.On("CreateWish", ctx, mock.Anything).Return(errors.New("mock error"))
		defer mockCreateWishFunc.Unset()

		wish := m.Wish{
			ID:      "2",
			Content: "Test Wish",
		}
		err := testWishService.CreateWish(ctx, wish)

		assert.Error(t, err)
		mockRepo.AssertExpectations(t)
	})
}
