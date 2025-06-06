package handler

import (
	"encoding/json"
	"net/http"
	"strconv"

	"github.com/gorilla/mux"
	m "github.com/savak1990/test-dynamodb-app/app/models"
	"github.com/savak1990/test-dynamodb-app/app/service"
	log "github.com/sirupsen/logrus"
)

type WishHandlerImpl struct {
	wishService service.WishService
}

func NewWishHandler(service service.WishService) *WishHandlerImpl {
	return &WishHandlerImpl{
		wishService: service,
	}
}

func (h *WishHandlerImpl) CreateWish(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()

	userId := mux.Vars(r)["userId"]
	if userId == "" {
		WriteJSONError(w, http.StatusBadRequest, m.ErrorCodeBadRequest, "userId is required")
		return
	}

	var wish m.Wish
	if err := json.NewDecoder(r.Body).Decode(&wish); err != nil {
		WriteJSONError(w, http.StatusBadRequest, m.ErrorCodeBadRequest, "Failed to decode request body: "+err.Error())
		return
	}
	defer r.Body.Close()

	log.WithContext(ctx).WithField("wish", wish).WithField("userId", userId).Debug("Handler: Creating wish")

	wish.UserId = userId

	outputWish, err := h.wishService.CreateWish(ctx, wish)
	if err != nil {
		WriteJSONError(w, http.StatusInternalServerError, m.ErrorCodeInternalServer, "Failed to create wish: "+err.Error())
		return
	}

	response, err := json.Marshal(outputWish)
	if err != nil {
		WriteJSONError(w, http.StatusInternalServerError, m.ErrorCodeBadResponse, "Failed to marshal response: "+err.Error())
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.Header().Set("Location", r.URL.Path+"/"+outputWish.WishId)
	w.WriteHeader(http.StatusCreated)
	w.Write(response)
}

func (h *WishHandlerImpl) UpdateWish(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()

	userId := mux.Vars(r)["userId"]
	if userId == "" {
		WriteJSONError(w, http.StatusBadRequest, m.ErrorCodeBadRequest, "userId is required")
		return
	}

	wishId := mux.Vars(r)["wishId"]
	if wishId == "" {
		WriteJSONError(w, http.StatusBadRequest, m.ErrorCodeBadRequest, "wishId is required")
		return
	}

	var wish m.Wish
	if err := json.NewDecoder(r.Body).Decode(&wish); err != nil {
		WriteJSONError(w, http.StatusBadRequest, m.ErrorCodeBadRequest, "Failed to decode request body: "+err.Error())
		return
	}
	defer r.Body.Close()

	wish.UserId = userId
	wish.WishId = wishId

	log.WithField("wish", wish).WithField("userId", userId).WithField("wishId", wishId).Debug("Handler: Updating wish")

	outputWish, err := h.wishService.UpdateWish(ctx, wish)
	if err != nil {
		WriteJSONError(w, http.StatusInternalServerError, m.ErrorCodeInternalServer, "Failed to update wish: "+err.Error())
		return
	}

	response, err := json.Marshal(outputWish)
	if err != nil {
		WriteJSONError(w, http.StatusInternalServerError, m.ErrorCodeBadResponse, "Failed to marshal response: "+err.Error())
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	w.Write(response)
}

func (h *WishHandlerImpl) DeleteWish(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()

	userId := mux.Vars(r)["userId"]
	if userId == "" {
		WriteJSONError(w, http.StatusBadRequest, m.ErrorCodeBadRequest, "userId is required")
		return
	}

	wishId := mux.Vars(r)["wishId"]
	if wishId == "" {
		WriteJSONError(w, http.StatusBadRequest, m.ErrorCodeBadRequest, "wishId is required")
		return
	}

	log.WithField("userId", userId).WithField("wishId", wishId).Debug("Handler: Deleting wish")

	err := h.wishService.DeleteWish(ctx, userId, wishId)
	if err != nil {
		WriteJSONError(w, http.StatusInternalServerError, m.ErrorCodeInternalServer, "Failed to delete wish: "+err.Error())
		return
	}

	w.WriteHeader(http.StatusNoContent)
}

func (h *WishHandlerImpl) GetWishByWishId(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()

	userId := mux.Vars(r)["userId"]
	if userId == "" {
		WriteJSONError(w, http.StatusBadRequest, m.ErrorCodeBadRequest, "userId is required")
		return
	}

	wishId := mux.Vars(r)["wishId"]
	if wishId == "" {
		WriteJSONError(w, http.StatusBadRequest, m.ErrorCodeBadRequest, "wishId is required")
		return
	}

	log.WithContext(ctx).WithField("userId", userId).WithField("wishId", wishId).Debug("Handler: Getting wish by wishId")

	wish, err := h.wishService.GetWishByWishId(ctx, userId, wishId)
	if err != nil {
		WriteJSONError(w, http.StatusInternalServerError, m.ErrorCodeInternalServer, "Failed to get wish: "+err.Error())
		return
	}

	response, err := json.Marshal(wish)
	if err != nil {
		WriteJSONError(w, http.StatusInternalServerError, m.ErrorCodeBadResponse, "Failed to marshal response: "+err.Error())
		return
	}

	w.Header().Set("Content-Type", "application/json")

	if wish == nil {
		w.WriteHeader(http.StatusNoContent)
	} else {
		w.WriteHeader(http.StatusOK)
		w.Write(response)
	}
}

func (h *WishHandlerImpl) GetWishList(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()

	userId := mux.Vars(r)["userId"]
	if userId == "" {
		WriteJSONError(w, http.StatusBadRequest, m.ErrorCodeBadRequest, "userId is required")
		return
	}

	sortBy := r.URL.Query().Get("sort_by")
	if sortBy != "" && sortBy != "priority" && sortBy != "created" && sortBy != "due" {
		WriteJSONError(w, http.StatusBadRequest, m.ErrorCodeBadRequest, "Invalid sort-by parameter: "+sortBy)
		return
	}

	order := r.URL.Query().Get("order")
	if order != "" && order != "asc" && order != "desc" {
		WriteJSONError(w, http.StatusBadRequest, m.ErrorCodeBadRequest, "Invalid order parameter: "+order)
		return
	}

	limitStr := r.URL.Query().Get("limit")
	var limit int32
	if limitStr != "" {
		limit64, err := strconv.ParseInt(limitStr, 10, 32)
		if err != nil {
			WriteJSONError(w, http.StatusBadRequest, m.ErrorCodeBadRequest, "Invalid limit parameter: "+err.Error())
			return
		}
		limit = int32(limit64)
		if limit < 1 || limit > 100 {
			WriteJSONError(w, http.StatusBadRequest, m.ErrorCodeBadRequest, "Limit must be between 1 and 100")
			return
		}
	}

	nextToken := r.URL.Query().Get("next_token")
	if nextToken != "" && len(nextToken) < 10 {
		WriteJSONError(w, http.StatusBadRequest, m.ErrorCodeBadRequest, "Invalid next_token parameter: "+nextToken)
		return
	}

	log.WithField("userId", userId).WithField("sortBy", sortBy).WithField("order", order).WithField("limit", limit).Debug("Handler: Getting wish list")

	wishes, nextToken, err := h.wishService.GetWishList(ctx, userId, sortBy, order, limit, nextToken)
	if err != nil {
		WriteJSONError(w, http.StatusInternalServerError, m.ErrorCodeInternalServer, "Failed to get wishes: "+err.Error())
		return
	}

	WriteJSONListResponse(w, wishes, nextToken)
}

// Ensure WishHandlerImpl implements WishHandler interface
var _ WishHandler = (*WishHandlerImpl)(nil)
