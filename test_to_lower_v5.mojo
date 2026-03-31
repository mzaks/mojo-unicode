"""Test the generated decision tree to_lower against to_lower3.csv."""

from to_lower_v5 import lower_utf8, _to_lower, Diff
from text import *

def parse_bytes(s: String) raises -> List[Int]:
    """Parse a space-separated byte string like '195 128' into a list of ints."""
    var result = List[Int]()
    for part in s.split(" "):
        if len(part) > 0:
            result.append(Int(String(part)))
    return result^


def test_individual_mappings() raises -> Int:
    """Test each mapping in the CSV individually.
    Returns the number of failures.
    """
    var failures = 0
    var tested = 0

    var content: String
    with open("to_lower3.csv", "r") as f:
        content = f.read()

    # Split into lines
    var lines = content.split("\n")

    for i in range(1, len(lines)):
        var line = lines[i]
        if len(line) < 5:
            continue

        var fields = String(line).split(",")
        if len(fields) < 12:
            continue

        var src = String(fields[2])
        var dst = String(fields[7])

        tested += 1

        if lower_utf8(src) != dst:
            failures += 1
            print(
                "FAIL lowering"
                + src
                + ": got "
                + lower_utf8(src)
                + " expected "
                + dst
            )

    print("Tested " + String(tested) + " mappings, " + String(failures) + " failures")
    return failures


def test_lower_utf8_strings() -> Int:
    """Test lower_utf8 on complete strings."""
    var failures = 0

    # ASCII test
    var r1 = lower_utf8(String("HELLO WORLD"))
    if r1 != "hello world":
        print("FAIL ASCII: got '" + r1 + "' expected 'hello world'")
        failures += 1

    # Latin extended
    var r2 = lower_utf8(String("ÀÁÂÃÄÅÆÇÈÉ"))
    if r2 != "àáâãäåæçèé":
        print("FAIL Latin: got '" + r2 + "' expected 'àáâãäåæçèé'")
        failures += 1

    # Greek
    var r3 = lower_utf8(String("ΑΒΓΔΕΖΗΘ"))
    if r3 != "αβγδεζηθ":
        print("FAIL Greek: got '" + r3 + "' expected 'αβγδεζηθ'")
        failures += 1

    # Cyrillic
    var r4 = lower_utf8(String("АБВГДЕЖЗ"))
    if r4 != "абвгдежз":
        print("FAIL Cyrillic: got '" + r4 + "' expected 'абвгдежз'")
        failures += 1

    # Mixed - already lowercase should not change
    var r5 = lower_utf8(String("already lowercase 123"))
    if r5 != "already lowercase 123":
        print("FAIL passthrough: got '" + r5 + "'")
        failures += 1

    return failures


def check(label: String, text: String) -> Int:
    var got = lower_utf8(text)
    var expected = text.lower()
    if got == expected:
        print("PASS " + label)
        return 0
    # Find first differing character for a useful error message
    var got_bytes = got.as_bytes()
    var exp_bytes = expected.as_bytes()
    var min_len = min(len(got_bytes), len(exp_bytes))
    for i in range(min_len):
        if got_bytes[i] != exp_bytes[i]:
            print(
                "FAIL "
                + label
                + ": first diff at byte "
                + String(i)
                + " got="
                + String(Int(got_bytes[i]))
                + " expected="
                + String(Int(exp_bytes[i]))
            )
            return 1
    print(
        "FAIL "
        + label
        + ": length mismatch got="
        + String(len(got_bytes))
        + " expected="
        + String(len(exp_bytes))
    )
    return 1


def main() raises:
    print("=== Testing individual mappings against CSV ===")
    var mapping_failures = test_individual_mappings()
    if mapping_failures == 0:
        print("All individual mapping tests PASSED!")

    print()
    print("=== Testing lower_utf8 on strings ===")
    var string_failures = test_lower_utf8_strings()
    if string_failures == 0:
        print("All string tests PASSED!")
    else:
        print(String(string_failures) + " string tests FAILED")

    print()
    var total = mapping_failures + string_failures
    if total == 0:
        print("ALL TESTS PASSED!")
    else:
        print("TOTAL FAILURES: " + String(total))

    print("=== Testing upper_utf8 on text examples ===")
    var failures = 0
    failures += check("Russian",  text_ru)
    failures += check("German",   text_de)
    failures += check("Greek",    text_gr)
    failures += check("Latin",    text_lt)
    failures += check("English",  text_en)
    failures += check("Adlam",    text_adlam)
    failures += check("Fula",     text_fulflude)
    failures += check("Chinese",  text_ch)
    print()
    if failures == 0:
        print("ALL TESTS PASSED!")
    else:
        print(String(failures) + " TESTS FAILED")
