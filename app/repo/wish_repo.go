package repo

import (
	"context"

	m "github.com/savak1990/test-dynamodb-app/app/models"
)

type WishRepository interface {
	CreateWish(ctx context.Context, wish m.Wish) error
}
