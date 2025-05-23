package models

type Wish struct {
	ID       string `json:"id" dynamodbav:"id"`
	Title    string `json:"title" dynamodbav:"title"`
	Content  string `json:"content" dynamodbav:"content"`
	Priority int    `json:"priority" dynamodbav:"priority"`
	Created  string `json:"created" dynamodbav:"created"`
	Updated  string `json:"updated" dynamodbav:"updated"`
	DueDate  string `json:"due_date" dynamodbav:"due_date"`
}
