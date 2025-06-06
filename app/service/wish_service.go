package service

import (
	"context"

	m "github.com/savak1990/test-dynamodb-app/app/models"
)

type WishService interface {
	CreateWish(ctx context.Context, wish m.Wish) (*m.Wish, error)
	GetWishByWishId(ctx context.Context, userId, wishId string) (*m.Wish, error)
	GetWishList(ctx context.Context, userId, sortBy, order string, limit int32, nextToken string) ([]m.Wish, string, error)
	UpdateWish(ctx context.Context, wish m.Wish) (*m.Wish, error)
	DeleteWish(ctx context.Context, userId, wishId string) error
}
