package service

import (
	"context"
	"errors"
	"time"

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

	if wish.Title == "" {
		return nil, errors.New(m.ErrorCodeBadRequest + ": Wish title cannot be empty")
	}

	if wish.WishId == "" {
		wish.WishId = uuid.NewString()
	}

	now := time.Now().UTC()
	nowFormatted := now.Format(time.RFC3339)
	wish.Created = nowFormatted
	wish.Updated = nowFormatted
	wish.All = "all"

	if wish.Priority == 0 {
		wish.Priority = 5
	}

	if wish.Due == "" {
		wish.Due = now.Add(30 * 24 * time.Hour).Format(time.RFC3339)
	}

	err := w.wishRepo.CreateWish(ctx, wish)
	if err != nil {
		return nil, err
	}
	return &wish, nil
}

func (w *WishServiceImpl) UpdateWish(ctx context.Context, wish m.Wish) (*m.Wish, error) {

	log.WithField("wish", wish).Debug("Service: Updating wish")

	wish.Updated = time.Now().UTC().Format(time.RFC3339)

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
		return w.wishRepo.GetAllWishes(ctx, w.wishRepo.GetGlobalSortIndexName(sortBy), scanForward)
	} else {
		return w.wishRepo.GetUserWishes(ctx, userId, w.wishRepo.GetLocalSortIndexName(sortBy), scanForward)
	}
}

// Ensure WishServiceImpl implements WishService interface
var _ WishService = (*WishServiceImpl)(nil)
