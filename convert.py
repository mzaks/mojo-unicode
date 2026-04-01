from time import perf_counter_ns
from text import (
    text_ru, text_de, text_en, text_lt,
    text_gr, text_adlam, text_fulflude, text_ch,
)


def lower(text: str) -> str:
    min_ns = float('inf')
    result = ""
    for _ in range(100):
        start = perf_counter_ns()
        result = text.lower()
        elapsed = perf_counter_ns() - start
        if elapsed < min_ns:
            min_ns = elapsed
    print(f"In: {min_ns / len(text.encode())} ns per byte")
    return result


def upper(text: str) -> str:
    min_ns = float('inf')
    result = ""
    for _ in range(100):
        start = perf_counter_ns()
        result = text.upper()
        elapsed = perf_counter_ns() - start
        if elapsed < min_ns:
            min_ns = elapsed
    print(f"In: {min_ns / len(text.encode())} ns per byte")
    return result


def main():
    for text, name in [
        (text_ru, "RU"),
        (text_de, "DE"),
        (text_en, "EN"),
        (text_lt, "LT"),
        (text_gr, "GR"),
        (text_adlam, "Adlam"),
        (text_fulflude, "Fulflude"),
        (text_ch, "CH"),
    ]:
        _ = lower(text)
        print(f"Lower {name} " + "-" * 20)
        _ = upper(text)
        print(f"Upper {name} " + "-" * 20)


if __name__ == "__main__":
    main()
