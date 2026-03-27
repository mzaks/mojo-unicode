"""Test upper_utf8 against String.upper() using real-world text examples,
and test individual mappings against to_upper.csv."""

from to_upper_v2 import upper_utf8, _to_upper, Diff
from text import text_ru, text_de, text_gr, text_lt, text_en, text_adlam, text_fulflude, text_ch


def parse_bytes(s: String) raises -> List[Int]:
    var result = List[Int]()
    for part in s.split(" "):
        if len(part) > 0:
            result.append(Int(String(part)))
    return result^


def test_individual_mappings() raises -> Int:
    """Test each mapping in to_upper.csv individually.
    Returns the number of failures.
    """
    var failures = 0
    var tested = 0

    var content: String
    with open("to_upper.csv", "r") as f:
        content = f.read()

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

        if upper_utf8(src) != dst:
            failures += 1
            print(
                "FAIL upper cassing"
                + src
                + ": got "
                + upper_utf8(src)
                + " expected "
                + dst
            )

    print("Tested " + String(tested) + " mappings, " + String(failures) + " failures")
    return failures


def check(label: String, text: String) -> Int:
    var got = upper_utf8(text)
    var expected = text.upper()
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
    print("=== Testing individual mappings against to_upper.csv ===")
    var mapping_failures = test_individual_mappings()
    if mapping_failures == 0:
        print("All individual mapping tests PASSED!")

    print()
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
