import subprocess
import time
import pytest
import requests
import os

# test/conftest.py

@pytest.fixture(scope="session", autouse=True)
def go_server():
    env = os.environ.copy()
    run_cmd = ["make", "build"]
    subprocess.run(run_cmd, env=env, check=True)
    server = subprocess.Popen(
        ["./build/ahorro-wishlist-service-vklyovan"], env=env
    )
    # Wait for server to be ready
    for _ in range(20):
        try:
            requests.get("http://localhost:8080/wishes/health")
            break
        except Exception:
            time.sleep(0.5)
    yield
    server.terminate()
    server.wait()

@pytest.fixture(scope="session")
def base_url():
    return "http://localhost:8080/wishes"