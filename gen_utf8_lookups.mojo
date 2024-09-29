from memory import bitcast

fn hex_to_int(value: String) -> Int:
    var multiplicator = 1
    var result = 0
    for i in range(len(value), 0, -1):
        var c = ord(value[i - 1]) - 0x30
        if c > 10:
            c -= 7
        result += c * multiplicator
        multiplicator *= 16
    return result

@value
struct TwoByteEntry(ComparableCollectionElement):
    var char: String
    var result: String
    var value: UInt16
    var mapping: SIMD[DType.uint8, 4]

    fn __lt__(self, other: Self) -> Bool:
        return self.value.__lt__(other.value)
    fn __le__(self, other: Self) -> Bool:
        return self.value.__le__(other.value)
    fn __gt__(self, other: Self) -> Bool:
        return self.value.__gt__(other.value)
    fn __ge__(self, other: Self) -> Bool:
        return self.value.__ge__(other.value)
    fn __eq__(self, other: Self) -> Bool:
        return self.value.__eq__(other.value)
    fn __ne__(self, other: Self) -> Bool:
        return self.value.__ne__(other.value)

@value
struct FourByteEntry(ComparableCollectionElement):
    var char: String
    var result: String
    var value: UInt32
    var mapping: SIMD[DType.uint8, 4]

    fn __lt__(self, other: Self) -> Bool:
        return self.value.__lt__(other.value)
    fn __le__(self, other: Self) -> Bool:
        return self.value.__le__(other.value)
    fn __gt__(self, other: Self) -> Bool:
        return self.value.__gt__(other.value)
    fn __ge__(self, other: Self) -> Bool:
        return self.value.__ge__(other.value)
    fn __eq__(self, other: Self) -> Bool:
        return self.value.__eq__(other.value)
    fn __ne__(self, other: Self) -> Bool:
        return self.value.__ne__(other.value)

def gen_two_bytes_lower_lookup(unicode_data: String, inout formatter: Formatter):
    var entries = List[TwoByteEntry]()
    for line in unicode_data.splitlines():
        var parts = line[].split(";")
        var mapping = parts[13]
        if len(mapping) > 0:
            var char = chr(hex_to_int(parts[0]))
            if char.byte_length() == 2:
                var u16 = char.unsafe_ptr().bitcast[DType.uint16]()[]
                var result = chr(hex_to_int(parts[13]))
                if result.byte_length() == 1:
                    entries.append(
                        TwoByteEntry(
                            char, result, u16, SIMD[DType.uint8, 4](
                                result.unsafe_ptr()[0],
                                0,
                                0,
                                1
                            )
                        )
                    )
                elif result.byte_length() == 2:
                    entries.append(
                        TwoByteEntry(
                            char, result, u16, SIMD[DType.uint8, 4](
                                result.unsafe_ptr()[0],
                                result.unsafe_ptr()[1],
                                0,
                                2
                            )
                        )
                    )
                elif result.byte_length() == 3:
                    entries.append(
                        TwoByteEntry(
                            char, result, u16, SIMD[DType.uint8, 4](
                                result.unsafe_ptr()[0],
                                result.unsafe_ptr()[1],
                                result.unsafe_ptr()[2],
                                3
                            )
                        )
                    )
                else:
                    raise "Unexpected " + result

    sort(entries)
    formatter.write_str("alias has_lower_case_2 = List[UInt16](\n")
    for e in entries:
        formatter.write_str("    ")
        formatter.write_str(str(e[].value).as_string_slice())
        formatter.write_str(", # ")
        formatter.write_str(" ")
        formatter.write_str(e[].char.as_string_slice())
        formatter.write_str("\n")

    formatter.write_str(")\n")

    formatter.write_str("alias lower_case_mapping_2 = List[SIMD[DType.uint8, 4]](\n")
    for e in entries:
        formatter.write_str("    SIMD[DType.uint8, 4](")
        for i in range(4):
            formatter.write_str(str(e[].mapping[i]).as_string_slice())
            formatter.write_str(", ")
        formatter.write_str("), # ")
        formatter.write_str(" ")
        formatter.write_str(e[].char.as_string_slice())
        formatter.write_str(" -> ")
        formatter.write_str(e[].result.as_string_slice())
        formatter.write_str("\n")

    formatter.write_str(")\n")

def gen_three_bytes_lower_lookup(unicode_data: String, inout formatter: Formatter):
    var entries = List[FourByteEntry]()
    for line in unicode_data.splitlines():
        var parts = line[].split(";")
        var mapping = parts[13]
        if len(mapping) > 0:
            var char = chr(hex_to_int(parts[0]))
            if char.byte_length() == 3:
                var bytes = char.unsafe_ptr().load[width=4]()
                bytes[3] = 0
                var u32 = bitcast[DType.uint32, 1](bytes)
                var result = chr(hex_to_int(parts[13]))
                if result.byte_length() == 1:
                    entries.append(
                        FourByteEntry(
                            char, result, u32, SIMD[DType.uint8, 4](
                                result.unsafe_ptr()[0],
                                0,
                                0,
                                1
                            )
                        )
                    )
                elif result.byte_length() == 2:
                    entries.append(
                        FourByteEntry(
                            char, result, u32, SIMD[DType.uint8, 4](
                                result.unsafe_ptr()[0],
                                result.unsafe_ptr()[1],
                                0,
                                2
                            )
                        )
                    )
                elif result.byte_length() == 3:
                    entries.append(
                        FourByteEntry(
                            char, result, u32, SIMD[DType.uint8, 4](
                                result.unsafe_ptr()[0],
                                result.unsafe_ptr()[1],
                                result.unsafe_ptr()[2],
                                3
                            )
                        )
                    )
                else:
                    raise "should not happen"

    sort(entries)
    formatter.write_str("alias has_lower_case_3 = List[UInt32](\n")
    for e in entries:
        formatter.write_str("    ")
        formatter.write_str(str(e[].value).as_string_slice())
        formatter.write_str(", # ")
        formatter.write_str(" ")
        formatter.write_str(e[].char.as_string_slice())
        formatter.write_str("\n")

    formatter.write_str(")\n")

    formatter.write_str("alias lower_case_mapping_3 = List[SIMD[DType.uint8, 4]](\n")
    for e in entries:
        formatter.write_str("    SIMD[DType.uint8, 4](")
        for i in range(4):
            formatter.write_str(str(e[].mapping[i]).as_string_slice())
            formatter.write_str(", ")
        formatter.write_str("), # ")
        formatter.write_str(" ")
        formatter.write_str(e[].char.as_string_slice())
        formatter.write_str(" -> ")
        formatter.write_str(e[].result.as_string_slice())
        formatter.write_str("\n")

    formatter.write_str(")\n")

def gen_four_bytes_lower_lookup(unicode_data: String, inout formatter: Formatter):
    var entries = List[FourByteEntry]()
    for line in unicode_data.splitlines():
        var parts = line[].split(";")
        var mapping = parts[13]
        if len(mapping) > 0:
            var char = chr(hex_to_int(parts[0]))
            if char.byte_length() == 4:
                var u32 = char.unsafe_ptr().bitcast[DType.uint32]()[]
                var result = chr(hex_to_int(parts[13]))
                if result.byte_length() != 4:
                    raise "Unexpected " + result
                entries.append(
                    FourByteEntry(
                        char, result, u32, SIMD[DType.uint8, 4](
                            result.unsafe_ptr()[0],
                            result.unsafe_ptr()[1],
                            result.unsafe_ptr()[2],
                            result.unsafe_ptr()[3],
                        )
                    )
                )
    sort(entries)
    formatter.write_str("alias has_lower_case_4 = List[UInt32](\n")
    for e in entries:
        formatter.write_str("    ")
        formatter.write_str(str(e[].value).as_string_slice())
        formatter.write_str(", # ")
        formatter.write_str(" ")
        formatter.write_str(e[].char.as_string_slice())
        formatter.write_str("\n")

    formatter.write_str(")\n")

    formatter.write_str("alias lower_case_mapping_4 = List[SIMD[DType.uint8, 4]](\n")
    for e in entries:
        formatter.write_str("    SIMD[DType.uint8, 4](")
        for i in range(4):
            formatter.write_str(str(e[].mapping[i]).as_string_slice())
            formatter.write_str(", ")
        formatter.write_str("), # ")
        formatter.write_str(" ")
        formatter.write_str(e[].char.as_string_slice())
        formatter.write_str(" -> ")
        formatter.write_str(e[].result.as_string_slice())
        formatter.write_str("\n")

    formatter.write_str(")\n")

def main():
    with open("Unicode-Data.txt", "r") as f:
        var csv_string = f.read()
        var std = Formatter.stdout()
        gen_two_bytes_lower_lookup(csv_string, std)
        gen_three_bytes_lower_lookup(csv_string, std)
        gen_four_bytes_lower_lookup(csv_string, std)