# Ahorro Wishlist Service

This project is a Go application that provides a REST API for managing user wishlists, backed by AWS DynamoDB. It includes infrastructure-as-code (Terraform), functional tests (pytest), and supports easy local and CI testing with isolated DynamoDB tables.

---

## Features

- RESTful API for creating and retrieving wishes per user
- DynamoDB as the backend (configurable table name)
- Infrastructure managed with Terraform modules
- Functional end-to-end tests using Python and pytest
- Easy local development and test setup via Makefile

---

## Prerequisites

- Go 1.20 or later
- Python 3.8+ (for functional tests)
- AWS CLI configured with appropriate credentials
- Terraform 1.3+ installed
- [Optional] Docker (if you want to use DynamoDB Local for development)

---

## Installation

1. **Clone the repository:**
    ```bash
    git clone https://github.com/your-username/test-dynamodb-app.git
    cd test-dynamodb-app
    ```

2. **Install Go dependencies:**
    ```bash
    go mod tidy
    ```

3. **Install Python dependencies (for tests):**
    ```bash
    python3 -m venv .venv
    source .venv/bin/activate
    pip install -r test/requirements.txt
    ```

4. **Install Terraform dependencies:**
    ```bash
    cd terraform
    terraform init
    cd ..
    ```

---

## Usage

### Run the Application

1. **Deploy DynamoDB table (using Terraform):**
    ```bash
    make deploy
    ```

2. **Run the Go server:**
    ```bash
    make run
    ```
    The server will start on `localhost:8080`.

3. **API Endpoints:**
    - `POST   /wishes/{userId}` — Create a wish for a user
    - `GET    /wishes/{userId}/{wishId}` — Get a wish by ID
    - `GET    /wishes/{userId}` — List all wishes for a user
    - `GET    /health` — Health check
    - `GET    /info` — Info endpoint

---

### Running Functional Tests

Functional tests will:
- Deploy a dedicated test DynamoDB table
- Start the Go server with the test table
- Run all Python/pytest tests
- Clean up the test table after

To run all functional tests:
```bash
make functional-test
```

---

### Clean Up

To destroy all infrastructure created by Terraform:
```bash
make undeploy
```

To remove build artifacts:
```bash
make clean
```

---

## Configuration

- The DynamoDB table name is configurable via environment variable `DYNAMODB_TABLE`.
- The Makefile and Terraform use `DB_TABLE_NAME` and `DB_TABLE_TEST_NAME` for production and test tables, respectively.
- You can override these variables when running `make`:
    ```bash
    make run DB_TABLE_NAME=my-custom-table
    ```

---

## Contributing

Contributions are welcome! Please open issues or submit pull requests.

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## Contact

For questions or feedback, please contact [your-email@example.com].