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

		inputWish := m.Wish{
			UserId:  "1",
			Content: "Test Wish",
		}
		outputWish, err := testWishService.CreateWish(ctx, inputWish)

		assert.NoError(t, err)
		assert.NotNil(t, outputWish)
		assert.Equal(t, "1", outputWish.UserId)
		assert.NotEmpty(t, outputWish.WishId)
		assert.Equal(t, inputWish.Content, outputWish.Content)
		mockRepo.AssertExpectations(t)
	})

	t.Run("SuccessWithUserId", func(t *testing.T) {
		createWishFunc := mockRepo.On("CreateWish", ctx, mock.Anything).Return(nil)
		defer createWishFunc.Unset()

		inputWish := m.Wish{
			UserId:  "1",
			WishId:  "2",
			Content: "Test Wish",
		}
		outputWish, err := testWishService.CreateWish(ctx, inputWish)

		assert.NoError(t, err)
		assert.NotNil(t, outputWish)
		assert.NotEmpty(t, outputWish.WishId)
		assert.NotEqual(t, inputWish.WishId, outputWish.WishId)
		assert.Equal(t, inputWish.Content, outputWish.Content)
		mockRepo.AssertExpectations(t)
	})

	t.Run("RepoReturnNil", func(t *testing.T) {
		mockCreateWishFunc := mockRepo.On("CreateWish", ctx, mock.Anything).Return(errors.New("mock error"))
		defer mockCreateWishFunc.Unset()

		inputWish := m.Wish{
			Content: "Test Wish",
		}
		outputWish, err := testWishService.CreateWish(ctx, inputWish)

		assert.Error(t, err)
		assert.Nil(t, outputWish)
		assert.Equal(t, "mock error", err.Error())
		mockRepo.AssertExpectations(t)
	})
}
