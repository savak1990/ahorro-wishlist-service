import pytest
import requests

def test_create_wish(base_url):
    response = requests.post(f"{base_url}/1", json={"content": "Test Wish"})
    assert response.status_code == 201
    data = response.json()
    assert "wishId" in data
    assert str(data["wishId"]) in response.headers["Location"]

def test_get_wish_by_id(base_url):
    response = requests.post(f"{base_url}/1", json={"content": "Another Test Wish"})
    wish_id = response.headers["Location"].split("/")[-1]

    response = requests.get(f"{base_url}/1/{wish_id}")
    assert response.status_code == 200
    data = response.json()
    assert data["content"] == "Another Test Wish"

def test_get_wish_list(base_url):
    response = requests.get(f"{base_url}/1")
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)  # Ensure the response is a list

def test_server_is_running(base_url):
    response = requests.get(f"{base_url}/info")
    assert response.status_code == 200  # Ensure the server is running and accessible