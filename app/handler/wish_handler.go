package handler

import "net/http"

type WishHandler interface {
	CreateWish(http.ResponseWriter, *http.Request)
}
