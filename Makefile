APP_NAME=test-dynamodb-app
APP_DIR=app
BUILD_DIR=./build
BINARY=$(BUILD_DIR)/$(APP_NAME)

.PHONY: all build test run clean

build:
	mkdir -p $(BUILD_DIR)
	cd $(APP_DIR) && go build -o ../$(BINARY) main.go	

test:
	cd $(APP_DIR) && go test ./...

run: build
	./$(BINARY)

clean:
	rm -f $(BUILD_DIR)