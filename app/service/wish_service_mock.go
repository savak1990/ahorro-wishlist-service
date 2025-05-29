package service

import (
	"context"

	m "github.com/savak1990/test-dynamodb-app/app/models"
	"github.com/stretchr/testify/mock"
)

type MockWishService struct {
	mock.Mock
}

func (svc *MockWishService) CreateWish(ctx context.Context, wish m.Wish) (*m.Wish, error) {
	args := svc.Called(ctx, wish)
	retWish := args.Get(0)
	if retWish == nil {
		return nil, args.Error(1)
	}
	return retWish.(*m.Wish), args.Error(1)
}

func (svc *MockWishService) GetWishByWishId(ctx context.Context, userId, wishId string) (*m.Wish, error) {
	args := svc.Called(ctx, userId, wishId)
	retWish := args.Get(0)
	if retWish == nil {
		return nil, args.Error(1)
	}
	return retWish.(*m.Wish), args.Error(1)
}

func (svc *MockWishService) GetWishList(ctx context.Context, userId, sortBy, order string) ([]m.Wish, error) {
	args := svc.Called(ctx, userId, sortBy, order)
	retWishes := args.Get(0)
	if retWishes == nil {
		return nil, args.Error(1)
	}
	return retWishes.([]m.Wish), args.Error(1)
}

func (svc *MockWishService) UpdateWish(ctx context.Context, wish m.Wish) (*m.Wish, error) {
	args := svc.Called(ctx, wish)
	retWish := args.Get(0)
	if retWish == nil {
		return nil, args.Error(1)
	}
	return retWish.(*m.Wish), args.Error(1)
}

func (svc *MockWishService) DeleteWish(ctx context.Context, userId, wishId string) error {
	args := svc.Called(ctx, userId, wishId)
	return args.Error(0)
}

// Ensure MockWishService implements WishService interface
var _ WishService = (*MockWishService)(nil)
