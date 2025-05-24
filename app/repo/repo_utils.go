package repo

import "github.com/aws/aws-sdk-go-v2/feature/dynamodb/attributevalue"

var dynamoDbMarshalMapFunc = attributevalue.MarshalMap
var dynamoDbUnmarshalMapFunc = attributevalue.UnmarshalMap
var dynamoDbUnmarshalListOfMapsFunc = attributevalue.UnmarshalListOfMaps
