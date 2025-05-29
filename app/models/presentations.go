package models

const (
	ErrorCodeBadRequest     = "BadRequest"
	ErrorCodeInternalServer = "InternalServerError"
	ErrorCodeNotFound       = "NotFound"
	ErrorCodeBadResponse    = "BadResponse"
)

type Error struct {
	Code    string `json:"code"`
	Message string `json:"message"`
}
