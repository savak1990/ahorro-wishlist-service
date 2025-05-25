package config

import "os"

type AppConfig struct {
	AWSRegion  string
	AWSProfile string
	TableName  string
}

func LoadConfig() AppConfig {
	return AppConfig{
		AWSRegion:  getEnv("AWS_REGION", "us-east-1"),
		AWSProfile: os.Getenv("AWS_PROFILE"),
		TableName:  os.Getenv("DYNAMODB_TABLE"),
	}
}

func getEnv(key, fallback string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return fallback
}
