APP_NAME=ahorro-wishlist-service
INSTANCE_NAME=$(shell whoami)
FULL_NAME=$(APP_NAME)-$(INSTANCE_NAME)
DB_TABLE_NAME=$(FULL_NAME)-db
DB_TABLE_TEST_NAME=$(FULL_NAME)-test-db

APP_DIR=app
BUILD_DIR=./build
BINARY=$(BUILD_DIR)/$(FULL_NAME)

.PHONY: all build test run clean functional-test deploy undeploy

build:
	mkdir -p $(BUILD_DIR)
	cd $(APP_DIR) && go build -o ../$(BINARY) main.go	

test:
	cd $(APP_DIR) && go test ./...

run:
	DYNAMODB_TABLE=$(DB_TABLE_NAME) ./$(BINARY)

functional-test:
	@if [ ! -d ".venv" ]; then python3 -m venv .venv; fi && \
	. .venv/bin/activate && python3 -m pip install -r test/requirements.txt && \
	cd deploy && terraform init && terraform apply -auto-approve -var="db_table_name=$(DB_TABLE_TEST_NAME)" && \
	DYNAMODB_TABLE=$(DB_TABLE_TEST_NAME) BINARY=$(BINARY) pytest ../test && \
	cd deploy && terraform destroy -auto-approve -var="db_table_name=$(DB_TABLE_TEST_NAME)"

deploy:
	cd terraform && terraform init && terraform apply -auto-approve -var="db_table_name=$(DB_TABLE_NAME)"

undeploy:
	cd terraform && terraform destroy -auto-approve -var="db_table_name=$(DB_TABLE_NAME)"

clean:
	rm -rf $(BUILD_DIR) $(.venv) .pytest_cache .coverage
