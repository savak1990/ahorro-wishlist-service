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

func (r *MockWishRepository) CreateWish(ctx context.Context, wish m.Wish) error {
	args := r.Called(ctx, wish)
	return args.Error(0)
}

func (r *MockWishRepository) GetWishByWishId(ctx context.Context, userId, wishId string) (*m.Wish, error) {
	args := r.Called(ctx, userId, wishId)
	var out *m.Wish
	if v := args.Get(0); v != nil {
		out = v.(*m.Wish)
	}
	return out, args.Error(1)
}

func (r *MockWishRepository) GetUserWishes(ctx context.Context, userId string, lsi string, scanForward bool, limit int32, nextToken string) ([]m.Wish, string, error) {
	args := r.Called(ctx, userId, lsi, scanForward, limit, nextToken)
	var out []m.Wish
	if v := args.Get(0); v != nil {
		out = v.([]m.Wish)
	}
	return out, args.String(1), args.Error(2)
}

func (r *MockWishRepository) UpdateWish(ctx context.Context, wish m.Wish) (*m.Wish, error) {
	args := r.Called(ctx, wish)
	var out *m.Wish
	if v := args.Get(0); v != nil {
		out = v.(*m.Wish)
	}
	return out, args.Error(1)
}

func (r *MockWishRepository) DeleteWish(ctx context.Context, userId, wishId string) error {
	args := r.Called(ctx, userId, wishId)
	return args.Error(0)
}

func (r *MockWishRepository) GetAllWishes(ctx context.Context, gsi string, scanForward bool, limit int32, nextToken string) ([]m.Wish, string, error) {
	args := r.Called(ctx, gsi, scanForward, limit, nextToken)
	var out []m.Wish
	if v := args.Get(0); v != nil {
		out = v.([]m.Wish)
	}
	return out, args.String(1), args.Error(2)
}

func (r *MockWishRepository) GetGlobalSortIndexName(sortBy string) string {
	args := r.Called(sortBy)
	return args.String(0)
}

func (r *MockWishRepository) GetLocalSortIndexName(sortBy string) string {
	args := r.Called(sortBy)
	return args.String(0)
}

// Ensure MockWishRepository implements WishRepository interface
var _ WishRepository = (*MockWishRepository)(nil)
