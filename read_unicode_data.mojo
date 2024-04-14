from csv import CsvTable, CsvBuilder

fn hex_to_int(value: String) -> Int:
    var multiplicator = 1
    var result = 0
    for i in range(len(value), 0, -1):
        var c = ord(value[i-1]) - 0x30
        if c > 10:
            c -= 7
        result += c * multiplicator
        multiplicator *= 16
    return result


@always_inline
fn _ctlz(val: Int) -> Int:
    return llvm_intrinsic["llvm.ctlz", Int](val, False)

@always_inline("nodebug")
fn _ctlz(val: SIMD) -> __type_of(val):
    return llvm_intrinsic["llvm.ctlz", __type_of(val)](val, False)

fn ord(s: String) -> Int:
    """Returns an integer that represents the given one-character string.

    Given a string representing one character, return an integer
    representing the code point of that character. For example, `ord("a")`
    returns the integer `97`. This is the inverse of the `chr()` function.

    Args:
        s: The input string, which must contain only a single character.

    Returns:
        An integer representing the code point of the given character.
    """
    # UTF-8 to Unicode conversion:              (represented as UInt32 BE)
    # 1: 0aaaaaaa                            -> 00000000 00000000 00000000 0aaaaaaa     a
    # 2: 110aaaaa 10bbbbbb                   -> 00000000 00000000 00000aaa aabbbbbb     a << 6  | b
    # 3: 1110aaaa 10bbbbbb 10cccccc          -> 00000000 00000000 aaaabbbb bbcccccc     a << 12 | b << 6  | c
    # 4: 11110aaa 10bbbbbb 10cccccc 10dddddd -> 00000000 000aaabb bbbbcccc ccdddddd     a << 18 | b << 12 | c << 6 | d
    var p = s._as_ptr().bitcast[DType.uint8]()
    var b1 = p.load()
    if (b1 >> 7) == 0:  # This is 1 byte ASCII char
        debug_assert(len(s) == 1, "input string length must be 1")
        return b1.to_int()
    var num_bytes = _ctlz(~b1)
    debug_assert(
        len(s) == num_bytes.to_int(), "input string must be one character"
    )
    var shift = (6 * (num_bytes - 1)).to_int()
    var b1_mask = 0b11111111 >> (num_bytes + 1)
    var result = (b1 & b1_mask).to_int() << shift
    for i in range(1, num_bytes):
        p += 1
        shift -= 6
        result |= (p.load() & 0b00111111).to_int() << shift
    return result

fn chr(c: Int) -> String:
    """Returns a string based on the given Unicode code point.

    Returns the string representing a character whose code point is the integer `c`.
    For example, `chr(97)` returns the string `"a"`. This is the inverse of the `ord()`
    function.

    Args:
        c: An integer that represents a code point.

    Returns:
        A string containing a single character based on the given code point.
    """
    # Unicode (represented as UInt32 BE) to UTF-8 conversion :
    # 1: 00000000 00000000 00000000 0aaaaaaa -> 0aaaaaaa                                a
    # 2: 00000000 00000000 00000aaa aabbbbbb -> 110aaaaa 10bbbbbb                       a >> 6  | 0b11000000, b       | 0b10000000
    # 3: 00000000 00000000 aaaabbbb bbcccccc -> 1110aaaa 10bbbbbb 10cccccc              a >> 12 | 0b11100000, b >> 6  | 0b10000000, c      | 0b10000000
    # 4: 00000000 000aaabb bbbbcccc ccdddddd -> 11110aaa 10bbbbbb 10cccccc 10dddddd     a >> 18 | 0b11110000, b >> 12 | 0b10000000, c >> 6 | 0b10000000, d | 0b10000000

    if (c >> 7) == 0:  # This is 1 byte ASCII char
        var p = DTypePointer[DType.int8].alloc(2)
        p.store(c)
        p.store(1, 0)
        return String(p, 2)

    @always_inline
    fn _utf8_len(val: Int) -> Int:
        debug_assert(val > 0x10FFFF, "Value is not a valid Unicode code point")
        alias sizes = SIMD[DType.int32, 4](
            0, 0b1111_111, 0b1111_1111_111, 0b1111_1111_1111_1111
        )
        var values = SIMD[DType.int32, 4](val)
        var mask = values > sizes
        return mask.cast[DType.uint8]().reduce_add().to_int()

    var num_bytes = _utf8_len(c)
    var p = DTypePointer[DType.uint8].alloc(num_bytes + 1)
    var shift = 6 * (num_bytes - 1)
    var mask = UInt8(0xFF) >> (num_bytes + 1)
    var num_bytes_marker = UInt8(0xFF) << (8 - num_bytes)
    p.store(((c >> shift) & mask) | num_bytes_marker)
    for i in range(1, num_bytes):
        shift -= 6
        p.store(i, ((c >> shift) & 0b00111111) | 0b10000000)
    p.store(num_bytes, 0)
    return String(p.bitcast[DType.int8](), num_bytes + 1)

fn push_bytes(s: String, inout builder: CsvBuilder):
    var ints: String = ""
    for b in s.as_bytes():
        ints += String(b[].cast[DType.uint8]())
        ints += " "
    builder.push(ints, False)

fn push_diff_bytes(s: String, sd: String, inout builder: CsvBuilder):
    var ints: String = ""
    for i in range(len(s.as_bytes())):
        var b = s.as_bytes()[i].cast[DType.uint8]()
        var d = sd.as_bytes()[i].cast[DType.uint8]()
        ints += String(d.to_int() - b.to_int())
        ints += " "
    builder.push(ints, False)

fn main() raises:
    var conversions = CsvBuilder("source hex", "source int", "source", "source len", "source bytes", "destination hex", "destination int", "destination", "destination len", "destination bytes", "diff", "diff bytes")
    with open("Unicode-Data.txt", "r") as f:
        var csv_string = f.read()
        # print(csv_string)
        var table = CsvTable[sep=ord(";")](csv_string)
        for i in range(table.row_count()):
            var upper = table.get(i, 13)
            if len(upper) > 0:
                conversions.push(table.get(i, 0), False)
                conversions.push(hex_to_int(table.get(i, 0)), False)
                var c = chr(hex_to_int(table.get(i, 0)))
                conversions.push(c, False)
                conversions.push(len(c), False)
                push_bytes(c, conversions)
                conversions.push(upper, False)
                conversions.push(hex_to_int(upper), False)
                var cu = chr(hex_to_int(upper))
                conversions.push(cu, False)
                conversions.push(len(cu), False)
                push_bytes(cu, conversions)
                conversions.push(hex_to_int(upper) - hex_to_int(table.get(i, 0)), False)
                push_diff_bytes(c, cu, conversions)
    with open("to_lower.csv", "w") as f:
        f.write(conversions^.finish())