from pricing import apply_discount


def test_apply_discount_reduces_price():
    assert apply_discount(200.0, 10) == 180.0
