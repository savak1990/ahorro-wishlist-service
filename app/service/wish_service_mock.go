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
