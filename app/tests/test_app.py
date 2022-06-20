from app import __version__
from app.app import hello


def test_version():
    assert __version__ == '0.1.0'

def test_hello_world():
    assert hello() == "Hello World!"
