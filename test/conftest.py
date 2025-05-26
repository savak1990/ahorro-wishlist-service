import subprocess
import time
import pytest
import requests
import os

@pytest.fixture(scope="session", autouse=True)
def go_server():
    env = os.environ.copy()

    # Require BINARY to be set in the environment
    binary_path = env.get("BINARY")
    if not binary_path:
        raise RuntimeError("BINARY environment variable must be set (passed via Makefile)")

    server = subprocess.Popen(
        [binary_path], env=env
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