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

	log.WithField("wish", wish).Debugf("Service: Creating wish...")

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
	wish.Version = 0

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

	curWish, err := w.wishRepo.GetWishByWishId(ctx, wish.UserId, wish.WishId)
	if err != nil {
		log.WithField("wishId", wish.WishId).WithField("userId", wish.UserId).Error("Service: Failed to fetch current wish")
		return nil, errors.New(m.ErrorCodeInternalServer + ": Failed to fetch wish (wishId: " + wish.WishId + ", userId: " + wish.UserId + "): " + err.Error())
	}

	if curWish == nil {
		log.WithField("wishId", wish.WishId).WithField("userId", wish.UserId).Warn("Service: Wish not found")
		return nil, errors.New(m.ErrorCodeNotFound + ": Wish not found (wishId: " + wish.WishId + ", userId: " + wish.UserId + ")")
	}

	wish.Updated = time.Now().UTC().Format(time.RFC3339)
	wish.Version = curWish.Version

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

func (w *WishServiceImpl) GetWishList(ctx context.Context, userId, sortBy, order string, limit int32, nextToken string) ([]m.Wish, string, error) {

	log.WithField("userId", userId).WithField("sortBy", sortBy).WithField("order", order).WithField("limit", limit).Debug("Service: Getting wish list")

	scanForward := true
	if order == "desc" {
		scanForward = false
	}

	if userId == "all" {
		return w.wishRepo.GetAllWishes(ctx, w.wishRepo.GetGlobalSortIndexName(sortBy), scanForward, limit, nextToken)
	} else {
		return w.wishRepo.GetUserWishes(ctx, userId, w.wishRepo.GetLocalSortIndexName(sortBy), scanForward, limit, nextToken)
	}
}

// Ensure WishServiceImpl implements WishService interface
var _ WishService = (*WishServiceImpl)(nil)
