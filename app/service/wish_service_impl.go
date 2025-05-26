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
	if wish.WishId == "" {
		wish.WishId = uuid.NewString()
	}
	err := w.wishRepo.CreateWish(ctx, wish)
	if err != nil {
		return nil, err
	}
	return &wish, nil
}

func (w *WishServiceImpl) GetWishByWishId(ctx context.Context, userId, wishId string) (*m.Wish, error) {
	return w.wishRepo.GetWishByWishId(ctx, userId, wishId)
}

func (w *WishServiceImpl) GetWishList(ctx context.Context, userId string) ([]m.Wish, error) {
	return w.wishRepo.GetWishList(ctx, userId)
}

func (w *WishServiceImpl) UpdateWish(ctx context.Context, wish m.Wish) (*m.Wish, error) {
	updatedWish, err := w.wishRepo.UpdateWish(ctx, wish)
	if err != nil {
		return nil, err
	}
	return updatedWish, nil
}

func (w *WishServiceImpl) DeleteWish(ctx context.Context, userId, wishId string) error {
	return w.wishRepo.DeleteWish(ctx, userId, wishId)
}

// Ensure WishServiceImpl implements WishService interface
var _ WishService = (*WishServiceImpl)(nil)
