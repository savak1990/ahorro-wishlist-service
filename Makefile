APP_NAME=ahorro
SERVICE_NAME=wishlist
INSTANCE_NAME=$(shell whoami)

FULL_NAME=$(APP_NAME)-$(SERVICE_NAME)-$(INSTANCE_NAME)
DB_TABLE_NAME=$(FULL_NAME)-db
DB_TABLE_TEST_NAME=$(FULL_NAME)-test-db

APP_DIR=app
APP_BUILD_DIR=./build/service-handler
APP_BINARY=$(APP_BUILD_DIR)/main

DBSTREAM_HANDLER_DIR=dbstream-handler
DBSTREAM_HANDLER_BUILD_DIR=./build/dbstream-handler
DBSTREAM_HANDLER_BINARY=$(DBSTREAM_HANDLER_BUILD_DIR)/bootstrap
DBSTREAM_HANDLER_FUNCTION_ZIP=../$(DBSTREAM_HANDLER_BUILD_DIR)/function.zip

SEED_PATH=./seed
SEED_DATA_FILE=$(SEED_PATH)/seed_data.json
SEED_SCRIPT=$(SEED_PATH)/seed_db.py
SEED_CLEAR_SCRIPT=$(SEED_PATH)/clear_db.py

.PHONY: all app-build app-test app-run dbstream-handler-build dbstream-handler-test dbstream-handler-package seed unseed clean functional-test deploy undeploy plan

# Main app targets
app-build:
	mkdir -p $(APP_BUILD_DIR)
	cd $(APP_DIR) && go build -o ../$(APP_BINARY) main.go	

app-test:
	cd $(APP_DIR) && go test ./...

app-run: app-build
	DYNAMODB_TABLE=$(DB_TABLE_NAME) ./$(APP_BINARY)

# DB Stream Handler targets
dbstream-handler-build:
	mkdir -p $(DBSTREAM_HANDLER_BUILD_DIR)
	cd $(DBSTREAM_HANDLER_DIR) && GOOS=linux GOARCH=amd64 go build -o ../$(DBSTREAM_HANDLER_BINARY) main.go

dbstream-handler-test:
	cd $(DBSTREAM_HANDLER_DIR) && go test ./...

dbstream-handler-package: dbstream-handler-build
	cd $(DBSTREAM_HANDLER_BUILD_DIR) && zip function.zip bootstrap

unseed:
	@if [ ! -d ".venv" ]; then python3 -m venv .venv; fi && \
	pip3 install -r $(SEED_PATH)/requirements.txt
	INSTANCE_NAME=$(INSTANCE_NAME) DYNAMODB_TABLE=$(DB_TABLE_NAME) python3 $(SEED_CLEAR_SCRIPT)

seed: unseed
	@if [ ! -d ".venv" ]; then python3 -m venv .venv; fi && \
	pip3 install -r $(SEED_PATH)/requirements.txt
	INSTANCE_NAME=$(INSTANCE_NAME) DYNAMODB_TABLE=$(DB_TABLE_NAME) SEED_DATA_FILE=$(SEED_DATA_FILE) python3 $(SEED_SCRIPT)

functional-test:
	@if [ ! -d ".venv" ]; then python3 -m venv .venv; fi && \
	. .venv/bin/activate && python3 -m pip install -r test/requirements.txt && \
	cd deploy && terraform init && terraform apply -auto-approve -var="db_table_name=$(DB_TABLE_TEST_NAME)" && \
	DYNAMODB_TABLE=$(DB_TABLE_TEST_NAME) BINARY=$(APP_BINARY) pytest ../test && \
	cd deploy && terraform destroy -auto-approve -var="db_table_name=$(DB_TABLE_TEST_NAME)"

plan:
	cd deploy && \
	terraform init \
		-backend-config="key=dev/$(SERVICE_NAME)/$(INSTANCE_NAME)/terraform.tfstate" && \
	terraform plan \
		-var="app_name=$(APP_NAME)" \
		-var="service_name=$(SERVICE_NAME)" \
		-var="env=$(INSTANCE_NAME)" \
		-var="dbstream_handler_zip=$(DBSTREAM_HANDLER_FUNCTION_ZIP)"

refresh:
	cd deploy && \
	terraform init \
		-backend-config="key=dev/$(SERVICE_NAME)/$(INSTANCE_NAME)/terraform.tfstate" && \
	terraform refresh \
		-var="app_name=$(APP_NAME)" \
		-var="service_name=$(SERVICE_NAME)" \
		-var="env=$(INSTANCE_NAME)" \
		-var="dbstream_handler_zip=$(DBSTREAM_HANDLER_FUNCTION_ZIP)"

deploy:
	cd deploy && \
	terraform init \
		-backend-config="key=dev/$(SERVICE_NAME)/$(INSTANCE_NAME)/terraform.tfstate" && \
	terraform apply -auto-approve \
		-var="app_name=$(APP_NAME)" \
		-var="service_name=$(SERVICE_NAME)" \
		-var="env=$(INSTANCE_NAME)" \
		-var="dbstream_handler_zip=$(DBSTREAM_HANDLER_FUNCTION_ZIP)"

deploy:
	cd deploy && \
	terraform init \
		-backend-config="key=dev/$(SERVICE_NAME)/$(INSTANCE_NAME)/terraform.tfstate" && \
	terraform apply -auto-approve \
		-var="app_name=$(APP_NAME)" \
		-var="service_name=$(SERVICE_NAME)" \
		-var="env=$(INSTANCE_NAME)" \
		-var="dbstream_handler_zip=$(DBSTREAM_HANDLER_FUNCTION_ZIP)"

undeploy:
	cd deploy && \
	terraform init \
		-backend-config="key=dev/$(SERVICE_NAME)/$(INSTANCE_NAME)/terraform.tfstate" && \
	terraform destroy -auto-approve \
		-var="app_name=$(APP_NAME)" \
		-var="service_name=$(SERVICE_NAME)" \
		-var="env=$(INSTANCE_NAME)" \
		-var="dbstream_handler_zip=$(DBSTREAM_HANDLER_FUNCTION_ZIP)"

clean:
	rm -rf ./build .venv .pytest_cache .coverage
