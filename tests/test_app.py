import http.client

def test_get_health_endpoint():
    conn = http.client.HTTPConnection("localhost", 5000)
    payload = ''
    headers = {}
    conn.request("GET", "/_healthz", payload, headers)
    res = conn.getresponse()
    data = res.read()
    assert "HEALTHY" in data.decode("utf-8")

def test_get_root_endpoint():
    conn = http.client.HTTPConnection("localhost", 5000)
    payload = ''
    headers = {}
    conn.request("GET", "", payload, headers)
    res = conn.getresponse()
    data = res.read()
    assert "user_agent" in data.decode("utf-8")
