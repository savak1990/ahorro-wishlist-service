package repo

import (
	"context"

	m "github.com/savak1990/test-dynamodb-app/app/models"
)

type WishRepository interface {
	CreateWish(ctx context.Context, wish m.Wish) error
	GetWishByWishId(ctx context.Context, userId, wishId string) (*m.Wish, error)
	GetWishList(ctx context.Context, userId string, scanForward bool) ([]m.Wish, error)
	UpdateWish(ctx context.Context, wish m.Wish) (*m.Wish, error)
	DeleteWish(ctx context.Context, userId, wishId string) error

	GetAllWishesSortedByPriority(ctx context.Context, scanForward bool) ([]m.Wish, error)
	GetAllWishesSortedByCreatedAt(ctx context.Context, scanForward bool) ([]m.Wish, error)
	GetWishesSortedByPriority(ctx context.Context, userId string, scanForward bool) ([]m.Wish, error)
	GetWishesSortedByCreatedAt(ctx context.Context, userId string, scanForward bool) ([]m.Wish, error)
}
