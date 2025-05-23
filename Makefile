APP_NAME=test-dynamodb-app
APP_DIR=app
BINARY=$(APP_DIR)/$(APP_NAME)

.PHONY: all build test run clean

all: build

build:
    cd $(APP_DIR) && go build -o $(APP_NAME) main.go

test:
    cd $(APP_DIR) && go test ./...

run: build
    cd $(APP_DIR) && ./$(APP_NAME)

clean:
    rm -f $(APP_DIR)/$(APP_NAME)
