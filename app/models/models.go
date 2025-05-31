package models

type Wish struct {
	UserId   string `json:"userId" dynamodbav:"userId"`
	WishId   string `json:"wishId" dynamodbav:"wishId"`
	Title    string `json:"title" dynamodbav:"title"`
	Content  string `json:"content" dynamodbav:"content"`
	Priority int    `json:"priority" dynamodbav:"priority"`
	Created  string `json:"created" dynamodbav:"created"`
	Updated  string `json:"updated" dynamodbav:"updated"`
	Due      string `json:"due" dynamodbav:"due"`
	All      string `json:"-" dynamodbav:"all"`
	Version  int    `json:"-" dynamodbav:"version"`
}

const (
	ErrorCodeBadRequest     = "BadRequest"
	ErrorCodeInternalServer = "InternalServerError"
	ErrorCodeNotFound       = "NotFound"
	ErrorCodeBadResponse    = "BadResponse"
)
