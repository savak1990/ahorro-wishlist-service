package handler

import "net/http"

type WishHandler interface {
	CreateWish(http.ResponseWriter, *http.Request)
	GetWishByWishId(http.ResponseWriter, *http.Request)
	GetWishList(http.ResponseWriter, *http.Request)
}
