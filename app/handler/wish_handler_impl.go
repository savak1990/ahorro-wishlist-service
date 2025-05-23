package handler

import (
	"encoding/json"
	"net/http"

	m "github.com/savak1990/test-dynamodb-app/app/models"
	"github.com/savak1990/test-dynamodb-app/app/service"
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
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	defer r.Body.Close()

	if err := h.wishService.CreateWish(ctx, wish); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusCreated)
}
