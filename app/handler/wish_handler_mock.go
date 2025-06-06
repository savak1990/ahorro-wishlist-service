package handler

import (
	"net/http"

	"github.com/stretchr/testify/mock"
)

type MockWishHandler struct {
	mock.Mock
}

func NewMockWishHandler() *MockWishHandler {
	return &MockWishHandler{}
}

func (m *MockWishHandler) CreateWish(w http.ResponseWriter, r *http.Request) {
	m.Called(w, r)
}

func (m *MockWishHandler) GetWishByWishId(w http.ResponseWriter, r *http.Request) {
	m.Called(w, r)
}

func (m *MockWishHandler) GetWishList(w http.ResponseWriter, r *http.Request) {
	m.Called(w, r)
}

func (m *MockWishHandler) UpdateWish(w http.ResponseWriter, r *http.Request) {
	m.Called(w, r)
}

func (m *MockWishHandler) DeleteWish(w http.ResponseWriter, r *http.Request) {
	m.Called(w, r)
}

// Ensure MockWishHandler implements WishHandler interface
var _ WishHandler = (*MockWishHandler)(nil)
