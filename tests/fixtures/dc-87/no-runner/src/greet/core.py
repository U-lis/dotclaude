def greet(name: str) -> str:
    if not name:
        raise ValueError("name is empty")
    return f"Hello, {name}!"


def farewell(name: str) -> str:
    return f"Goodbye, {name}!"
