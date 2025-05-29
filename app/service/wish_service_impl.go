package service

import (
	"context"
	"errors"

	"github.com/google/uuid"
	m "github.com/savak1990/test-dynamodb-app/app/models"
	"github.com/savak1990/test-dynamodb-app/app/repo"
	log "github.com/sirupsen/logrus"
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

	log.WithField("wish", wish).Debugf("Service: Creating wish")

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

func (w *WishServiceImpl) GetWishList(ctx context.Context, userId, sortBy, order string) ([]m.Wish, error) {

	log.WithField("userId", userId).WithField("sortBy", sortBy).WithField("order", order).Debug("Service: Getting wish list")

	scanForward := true
	if order == "desc" {
		scanForward = false
	}

	if userId == "all" {
		if sortBy == "priority" {
			return w.wishRepo.GetAllWishesSortedByPriority(ctx, scanForward)
		} else if sortBy == "created" {
			return w.wishRepo.GetAllWishesSortedByCreatedAt(ctx, scanForward)
		} else {
			return nil, errors.New(m.ErrorCodeBadRequest)
		}
	} else {
		if sortBy == "priority" {
			return w.wishRepo.GetWishesSortedByPriority(ctx, userId, scanForward)
		} else if sortBy == "created" {
			return w.wishRepo.GetWishesSortedByCreatedAt(ctx, userId, scanForward)
		} else {
			return w.wishRepo.GetWishList(ctx, userId, scanForward)
		}
	}
}

func (w *WishServiceImpl) UpdateWish(ctx context.Context, wish m.Wish) (*m.Wish, error) {

	log.WithField("wish", wish).Debug("Service: Updating wish")

	updatedWish, err := w.wishRepo.UpdateWish(ctx, wish)
	if err != nil {
		return nil, err
	}
	return updatedWish, nil
}

func (w *WishServiceImpl) DeleteWish(ctx context.Context, userId, wishId string) error {
	log.WithField("userId", userId).WithField("wishId", wishId).Debug("Service: Deleting wish")
	return w.wishRepo.DeleteWish(ctx, userId, wishId)
}

// Ensure WishServiceImpl implements WishService interface
var _ WishService = (*WishServiceImpl)(nil)
