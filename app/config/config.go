package config

import "os"

type AppConfig struct {
	AWSRegion  string
	AWSProfile string
}

func LoadConfig() AppConfig {
	return AppConfig{
		AWSRegion:  getEnv("AWS_REGION", "us-east-1"),
		AWSProfile: os.Getenv("AWS_PROFILE"), // optional
	}
}

func getEnv(key, fallback string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return fallback
}
