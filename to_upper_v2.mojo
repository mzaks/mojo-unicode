# from std.collections.string._utf8 import _utf8_first_byte_sequence_length
from std.bit import count_leading_zeros
from to_upper import _to_upper

comptime Diff = SIMD[DType.int16, 8]


def upper_utf8(s: String) -> String:
    """Convert a UTF-8 encoded string to uppercase using a decision tree.
    Uses a 16-byte SIMD fast path for aligned runs of pure ASCII.

    Args:
        s: Input string.

    Returns:
        A new string with all characters converted to uppercase.
    """
    comptime SIMD_WIDTH = 8
    var byte_len = s.byte_length()
    var capacity = byte_len // 2 * 3 + 1
    var result = String(capacity=capacity)
    var buf = result.unsafe_ptr_mut()
    var offset = 0
    var p = s.unsafe_ptr()
    var count = 0
    while offset < byte_len:
        if offset + SIMD_WIDTH <= byte_len:
            var vec = (p + offset).load[SIMD_WIDTH]()
            if vec.le(127).reduce_and():
                var is_lower = vec.ge(97) & vec.le(122)
                var delta = is_lower.select(
                    SIMD[DType.uint8, SIMD_WIDTH](224), SIMD[DType.uint8, SIMD_WIDTH](0)
                )
                buf.store(vec + delta)
                buf += SIMD_WIDTH
                count += SIMD_WIDTH
                offset += SIMD_WIDTH
                continue
        var b0 = p[offset]
        var char_length = Int(
            UInt8(b0 >> 7 == 0) * 1
            + count_leading_zeros(~b0)
        )
        if count + 6 >= capacity:
            capacity *= 2
            buf = result.unsafe_ptr_mut(capacity)
            buf += count
        if char_length == 1:
            buf[0] = (Byte(b0 + _to_upper(b0)))
            buf += 1
            count += 1
        elif char_length == 2:
            var b1 = p[offset + 1]
            var diff = _to_upper(b0, b1)
            var out_len = Int(diff[6])
            buf[0] = Byte(Int16(b0) + diff[0])
            if out_len >= 2:
                buf[1] = (Byte(Int16(b1) + diff[1]))
            if out_len >= 3:
                buf[2] = (Byte(diff[2]))
            if out_len >= 4:
                buf[3] = (Byte(diff[3]))
            if out_len >= 5:
                buf[4] = (Byte(diff[4]))
            if out_len >= 6:
                buf[5] = (Byte(diff[5]))
            buf += out_len
            count += out_len
        elif char_length == 3:
            var b1 = p[offset + 1]
            var b2 = p[offset + 2]
            var diff = _to_upper(b0, b1, b2)
            var out_len = Int(diff[6])
            buf[0] = (Byte(Int16(b0) + diff[0]))
            if out_len >= 2:
                buf[1] = (Byte(Int16(b1) + diff[1]))
            if out_len >= 3:
                buf[2] = (Byte(Int16(b2) + diff[2]))
            if out_len >= 4:
                buf[3] = (Byte(diff[3]))
            if out_len >= 5:
                buf[4] = (Byte(diff[4]))
            if out_len >= 6:
                buf[5] = (Byte(diff[5]))
            buf += out_len
            count += out_len
        elif char_length == 4:
            var b1 = p[offset + 1]
            var b2 = p[offset + 2]
            var b3 = p[offset + 3]
            var diff = _to_upper(b0, b1, b2, b3)
            buf[0] = (Byte(Int16(b0) + diff[0]))
            buf[1] = (Byte(Int16(b1) + diff[1]))
            buf[2] = (Byte(Int16(b2) + diff[2]))
            buf[3] = (Byte(Int16(b3) + diff[3]))
            buf += 4
            count += 4
        offset += char_length
    buf[0] = 0
    result.resize(unsafe_uninit_length=count)
    return result
