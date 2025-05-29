package repo

import (
	"context"

	m "github.com/savak1990/test-dynamodb-app/app/models"
)

type WishRepository interface {
	CreateWish(ctx context.Context, wish m.Wish) error
	UpdateWish(ctx context.Context, wish m.Wish) (*m.Wish, error)
	DeleteWish(ctx context.Context, userId, wishId string) error

	GetWishByWishId(ctx context.Context, userId, wishId string) (*m.Wish, error)
	GetUserWishes(ctx context.Context, userId string, lsi string, scanForward bool) ([]m.Wish, error)
	GetAllWishes(ctx context.Context, gsi string, scanForward bool) ([]m.Wish, error)

	GetGlobalSortIndexName(sortBy string) string
	GetLocalSortIndexName(sortBy string) string
}
