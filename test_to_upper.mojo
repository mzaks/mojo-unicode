"""Test upper_utf8 against String.upper() using real-world text examples,
and test individual mappings against to_upper.csv."""

from to_upper import upper_utf8, _to_upper, Diff
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

        var src_hex = String(fields[0])
        var src_len = Int(String(fields[3]))
        var src_bytes_str = String(fields[4])
        var dst_len = Int(String(fields[8]))
        var dst_bytes_str = String(fields[9])

        var src_bytes = parse_bytes(src_bytes_str)
        var dst_bytes = parse_bytes(dst_bytes_str)

        tested += 1

        if src_len == 1:
            var delta = _to_upper(UInt8(src_bytes[0]))
            var result_byte = Int(UInt8(src_bytes[0]) + delta)
            if result_byte != dst_bytes[0]:
                print(
                    "FAIL 1-byte U+"
                    + src_hex
                    + ": got "
                    + String(result_byte)
                    + " expected "
                    + String(dst_bytes[0])
                )
                failures += 1

        elif src_len == 2:
            var diff = _to_upper(UInt8(src_bytes[0]), UInt8(src_bytes[1]))
            var d0 = Int(diff[0])
            var d1 = Int(diff[1])
            var out_len = Int(diff[6])

            var ok = True
            if out_len != dst_len:
                ok = False
            else:
                var r0 = (src_bytes[0] + d0) & 0xFF
                if r0 != dst_bytes[0]:
                    ok = False
                if out_len >= 2:
                    var r1 = (src_bytes[1] + d1) & 0xFF
                    if r1 != dst_bytes[1]:
                        ok = False
                if out_len >= 3:
                    if Int(diff[2]) & 0xFF != dst_bytes[2]:
                        ok = False
                if out_len >= 4:
                    if Int(diff[3]) & 0xFF != dst_bytes[3]:
                        ok = False
                if out_len >= 5:
                    if Int(diff[4]) & 0xFF != dst_bytes[4]:
                        ok = False
                if out_len >= 6:
                    if Int(diff[5]) & 0xFF != dst_bytes[5]:
                        ok = False

            if not ok:
                print(
                    "FAIL 2-byte U+"
                    + src_hex
                    + " src="
                    + src_bytes_str
                    + " diff=("
                    + String(d0)
                    + ","
                    + String(d1)
                    + ",...,out_len="
                    + String(out_len)
                    + ")"
                    + " expected dst="
                    + dst_bytes_str
                )
                failures += 1

        elif src_len == 3:
            var diff = _to_upper(
                UInt8(src_bytes[0]), UInt8(src_bytes[1]), UInt8(src_bytes[2])
            )
            var d0 = Int(diff[0])
            var d1 = Int(diff[1])
            var d2 = Int(diff[2])
            var out_len = Int(diff[6])

            var ok = True
            if out_len != dst_len:
                ok = False
            else:
                var r0 = (src_bytes[0] + d0) & 0xFF
                if r0 != dst_bytes[0]:
                    ok = False
                if out_len >= 2:
                    var r1 = (src_bytes[1] + d1) & 0xFF
                    if r1 != dst_bytes[1]:
                        ok = False
                if out_len >= 3:
                    var r2 = (src_bytes[2] + d2) & 0xFF
                    if r2 != dst_bytes[2]:
                        ok = False
                if out_len >= 4:
                    if Int(diff[3]) & 0xFF != dst_bytes[3]:
                        ok = False
                if out_len >= 5:
                    if Int(diff[4]) & 0xFF != dst_bytes[4]:
                        ok = False
                if out_len >= 6:
                    if Int(diff[5]) & 0xFF != dst_bytes[5]:
                        ok = False

            if not ok:
                print(
                    "FAIL 3-byte U+"
                    + src_hex
                    + " src="
                    + src_bytes_str
                    + " diff=("
                    + String(d0)
                    + ","
                    + String(d1)
                    + ","
                    + String(d2)
                    + ",...,out_len="
                    + String(out_len)
                    + ")"
                    + " expected dst="
                    + dst_bytes_str
                )
                failures += 1

        elif src_len == 4:
            var diff = _to_upper(
                UInt8(src_bytes[0]),
                UInt8(src_bytes[1]),
                UInt8(src_bytes[2]),
                UInt8(src_bytes[3]),
            )
            var d0 = Int(diff[0])
            var d1 = Int(diff[1])
            var d2 = Int(diff[2])
            var d3 = Int(diff[3])

            var r0 = (src_bytes[0] + d0) & 0xFF
            var r1 = (src_bytes[1] + d1) & 0xFF
            var r2 = (src_bytes[2] + d2) & 0xFF
            var r3 = (src_bytes[3] + d3) & 0xFF

            if (
                r0 != dst_bytes[0]
                or r1 != dst_bytes[1]
                or r2 != dst_bytes[2]
                or r3 != dst_bytes[3]
            ):
                print(
                    "FAIL 4-byte U+"
                    + src_hex
                    + " src="
                    + src_bytes_str
                    + " diff=("
                    + String(d0)
                    + ","
                    + String(d1)
                    + ","
                    + String(d2)
                    + ","
                    + String(d3)
                    + ")"
                    + " expected dst="
                    + dst_bytes_str
                )
                failures += 1

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
