package service

import (
	"context"

	m "github.com/savak1990/test-dynamodb-app/app/models"
)

type WishService interface {
	CreateWish(ctx context.Context, wish m.Wish) (*m.Wish, error)
}
