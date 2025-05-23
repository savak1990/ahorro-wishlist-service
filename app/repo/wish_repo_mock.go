package repo

import (
	"context"

	m "github.com/savak1990/test-dynamodb-app/app/models"
	"github.com/stretchr/testify/mock"
)

type MockWishRepository struct {
	mock.Mock
}

func NewMockWishRepository() *MockWishRepository {
	return &MockWishRepository{}
}

func (m *MockWishRepository) CreateWish(ctx context.Context, wish m.Wish) error {
	args := m.Called(ctx, wish)
	return args.Error(0)
}
