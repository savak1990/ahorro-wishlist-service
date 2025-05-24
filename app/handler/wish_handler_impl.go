package handler

import (
	"encoding/json"
	"net/http"

	"github.com/gorilla/mux"
	m "github.com/savak1990/test-dynamodb-app/app/models"
	"github.com/savak1990/test-dynamodb-app/app/service"
	"github.com/savak1990/test-dynamodb-app/app/utils"
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
		utils.WriteJSONError(w, http.StatusBadRequest, m.ErrorCodeBadRequest, "userId is required")
		return
	}

	var wish m.Wish
	if err := json.NewDecoder(r.Body).Decode(&wish); err != nil {
		utils.WriteJSONError(w, http.StatusBadRequest, m.ErrorCodeBadRequest, "Failed to decode request body: "+err.Error())
		return
	}
	defer r.Body.Close()

	wish.UserId = userId

	outputWish, err := h.wishService.CreateWish(ctx, wish)
	if err != nil {
		utils.WriteJSONError(w, http.StatusInternalServerError, m.ErrorCodeInternalServer, "Failed to create wish: "+err.Error())
		return
	}

	response, err := json.Marshal(outputWish)
	if err != nil {
		utils.WriteJSONError(w, http.StatusInternalServerError, m.ErrorCodeBadResponse, "Failed to marshal response: "+err.Error())
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.Header().Set("Location", r.URL.Path+"/"+outputWish.WishId)
	w.WriteHeader(http.StatusCreated)
	w.Write(response)
}

func (h *WishHandlerImpl) GetWishByWishId(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()

	userId := mux.Vars(r)["userId"]
	if userId == "" {
		utils.WriteJSONError(w, http.StatusBadRequest, m.ErrorCodeBadRequest, "userId is required")
		return
	}

	wishId := mux.Vars(r)["wishId"]
	if wishId == "" {
		utils.WriteJSONError(w, http.StatusBadRequest, m.ErrorCodeBadRequest, "wishId is required")
		return
	}

	wish, err := h.wishService.GetWishByWishId(ctx, userId, wishId)
	if err != nil {
		utils.WriteJSONError(w, http.StatusInternalServerError, m.ErrorCodeInternalServer, "Failed to get wish: "+err.Error())
		return
	}

	response, err := json.Marshal(wish)
	if err != nil {
		utils.WriteJSONError(w, http.StatusInternalServerError, m.ErrorCodeBadResponse, "Failed to marshal response: "+err.Error())
		return
	}

	w.Header().Set("Content-Type", "application/json")

	if wish == nil {
		w.WriteHeader(http.StatusNoContent)
		return
	} else {
		w.Write(response)
		w.WriteHeader(http.StatusOK)
	}
}

func (h *WishHandlerImpl) GetWishList(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()

	userId := mux.Vars(r)["userId"]
	if userId == "" {
		utils.WriteJSONError(w, http.StatusBadRequest, m.ErrorCodeBadRequest, "userId is required")
		return
	}

	wishes, err := h.wishService.GetWishList(ctx, userId)
	if err != nil {
		utils.WriteJSONError(w, http.StatusInternalServerError, m.ErrorCodeInternalServer, "Failed to get wishes: "+err.Error())
		return
	}

	response, err := json.Marshal(wishes)
	if err != nil {
		utils.WriteJSONError(w, http.StatusInternalServerError, m.ErrorCodeBadResponse, "Failed to marshal response: "+err.Error())
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	w.Write(response)
}
