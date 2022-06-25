import pytest

from urllib.request import urlopen

@pytest.fixture(scope="session")
def httpserver_listen_address():
    return ("localhost", 5000)


def test_get_app_endpoint(httpserver):
    body = "user_agent"
    endpoint = ""
    httpserver.expect_request(endpoint).respond_with_data(body)
    with urlopen(httpserver.url_for(endpoint)) as response:
        result = response.read().decode()
    assert body in result

def test_get_healthz_endpoint(httpserver):
    body = "HEALTH"
    endpoint = "/_healthz"
    httpserver.expect_request(endpoint).respond_with_data(body)
    with urlopen(httpserver.url_for(endpoint)) as response:
        result = response.read().decode()
    assert body in result
