"""Test the generated decision tree to_lower against to_lower.csv."""

from to_lower_v2 import lower_utf8, _to_lower, Diff


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
    with open("to_lower.csv", "r") as f:
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

        var src_hex = String(fields[0])
        var src_len = Int(String(fields[3]))
        var src_bytes_str = String(fields[4])
        var dst_len = Int(String(fields[8]))
        var dst_bytes_str = String(fields[9])

        var src_bytes = parse_bytes(src_bytes_str)
        var dst_bytes = parse_bytes(dst_bytes_str)

        tested += 1

        if src_len == 1:
            var delta = _to_lower(UInt8(src_bytes[0]))
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
            var diff = _to_lower(UInt8(src_bytes[0]), UInt8(src_bytes[1]))
            var d0 = Int(diff[0])
            var d1 = Int(diff[1])
            var extra = Int(diff[2])
            var out_len = Int(diff[3])

            var ok = True
            if out_len != dst_len:
                ok = False
            elif out_len == 1:
                var r0 = (src_bytes[0] + d0) & 0xFF
                if r0 != dst_bytes[0]:
                    ok = False
            elif out_len == 3:
                var r0 = (src_bytes[0] + d0) & 0xFF
                var r1 = (src_bytes[1] + d1) & 0xFF
                var r2 = extra & 0xFF
                if r0 != dst_bytes[0] or r1 != dst_bytes[1] or r2 != dst_bytes[2]:
                    ok = False
            else:  # out_len == 2
                var r0 = (src_bytes[0] + d0) & 0xFF
                var r1 = (src_bytes[1] + d1) & 0xFF
                if r0 != dst_bytes[0] or r1 != dst_bytes[1]:
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
                    + ","
                    + String(extra)
                    + ","
                    + String(out_len)
                    + ")"
                    + " expected dst="
                    + dst_bytes_str
                )
                failures += 1

        elif src_len == 3:
            var diff = _to_lower(
                UInt8(src_bytes[0]), UInt8(src_bytes[1]), UInt8(src_bytes[2])
            )
            var d0 = Int(diff[0])
            var d1 = Int(diff[1])
            var d2 = Int(diff[2])
            var out_len = Int(diff[3])

            var ok = True
            if out_len != dst_len:
                ok = False
            elif out_len == 1:
                var r0 = (src_bytes[0] + d0) & 0xFF
                if r0 != dst_bytes[0]:
                    ok = False
            elif out_len == 2:
                var r0 = (src_bytes[0] + d0) & 0xFF
                var r1 = (src_bytes[1] + d1) & 0xFF
                if r0 != dst_bytes[0] or r1 != dst_bytes[1]:
                    ok = False
            else:  # out_len == 3
                var r0 = (src_bytes[0] + d0) & 0xFF
                var r1 = (src_bytes[1] + d1) & 0xFF
                var r2 = (src_bytes[2] + d2) & 0xFF
                if r0 != dst_bytes[0] or r1 != dst_bytes[1] or r2 != dst_bytes[2]:
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
                    + ","
                    + String(out_len)
                    + ")"
                    + " expected dst="
                    + dst_bytes_str
                )
                failures += 1

        elif src_len == 4:
            var diff = _to_lower(
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
