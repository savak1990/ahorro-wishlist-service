package service

import (
	"context"

	m "github.com/savak1990/test-dynamodb-app/app/models"
	"github.com/stretchr/testify/mock"
)

type MockWishService struct {
	mock.Mock
}

func (m *MockWishService) CreateWish(ctx context.Context, wish m.Wish) error {
	args := m.Called(ctx, wish)
	return args.Error(0)
}
