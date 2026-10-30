import pytest

from greet import farewell, greet


def test_greet_returns_greeting():
    assert greet("Ann") == "Hello, Ann!"


def test_greet_rejects_empty_name():
    with pytest.raises(ValueError):
        greet("")


def test_farewell_returns_farewell():
    assert farewell("Ann") == "Goodbye, Ann!"
