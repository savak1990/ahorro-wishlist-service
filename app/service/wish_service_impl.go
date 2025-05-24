package service

import (
	"context"

	"github.com/google/uuid"
	m "github.com/savak1990/test-dynamodb-app/app/models"
	"github.com/savak1990/test-dynamodb-app/app/repo"
)

type WishServiceImpl struct {
	wishRepo repo.WishRepository
}

func NewWishService(wishRepository repo.WishRepository) *WishServiceImpl {
	return &WishServiceImpl{
		wishRepo: wishRepository,
	}
}

func (w *WishServiceImpl) CreateWish(ctx context.Context, wish m.Wish) (*m.Wish, error) {
	wish.UserId = uuid.NewString()
	err := w.wishRepo.CreateWish(ctx, wish)
	if err != nil {
		return nil, err
	}
	return &wish, nil
}
