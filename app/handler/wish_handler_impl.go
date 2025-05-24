package handler

import (
	"encoding/json"
	"net/http"

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

	var wish m.Wish
	if err := json.NewDecoder(r.Body).Decode(&wish); err != nil {
		utils.WriteJSONError(w, http.StatusBadRequest, m.ErrorCodeBadRequest, "Failed to decode request body: "+err.Error())
		return
	}
	defer r.Body.Close()

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
