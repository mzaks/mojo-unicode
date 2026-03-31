from std.bit import count_leading_zeros

comptime Diff = SIMD[DType.uint8, 8]


@always_inline
def _to_upper(a: UInt8) -> UInt8:
    """Branch-free ASCII uppercase. Returns XOR mask (32 for a-z, 0 otherwise)."""
    var is_lower = (a >= 97) & (a <= 122)
    return UInt8(is_lower) * 32


comptime _lut_194 = SIMD[DType.uint8, 64](0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 41, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
comptime _lut_195 = SIMD[DType.uint8, 64](0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 79, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 0, 10, 10, 10, 10, 10, 10, 10, 38)
comptime _lut_196 = SIMD[DType.uint8, 64](0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 77, 0, 1, 0, 1, 0, 1, 0, 0, 2, 0, 3, 0, 2, 0)
comptime _lut_197 = SIMD[DType.uint8, 64](29, 0, 2, 0, 3, 0, 2, 0, 6, 56, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 2, 0, 3, 0, 2, 80)
comptime _lut_198 = SIMD[DType.uint8, 64](47, 0, 0, 1, 0, 1, 0, 0, 6, 0, 0, 0, 3, 0, 0, 0, 0, 0, 2, 0, 0, 25, 0, 0, 0, 1, 45, 0, 0, 0, 46, 0, 0, 1, 0, 1, 0, 1, 0, 0, 6, 0, 0, 0, 0, 1, 0, 0, 9, 0, 0, 0, 3, 0, 2, 0, 0, 1, 0, 0, 0, 1, 0, 19)
comptime _lut_199 = SIMD[DType.uint8, 64](0, 0, 0, 0, 1, 0, 2, 6, 0, 1, 1, 0, 3, 0, 2, 0, 9, 0, 2, 0, 3, 0, 2, 0, 6, 0, 2, 0, 3, 22, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 78, 2, 0, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 1)
comptime _lut_200 = SIMD[DType.uint8, 64](0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 69)
comptime _lut_201 = SIMD[DType.uint8, 64](76, 0, 2, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 74, 73, 75, 49, 49, 0, 52, 51, 0, 50, 0, 48, 63, 0, 0, 0, 55, 68, 0, 57, 0, 67, 66, 0, 58, 58, 65, 72, 64, 0, 0, 55, 0, 70, 54, 0, 0, 53, 0, 0, 0, 0, 0, 0, 0, 71, 0, 0)
comptime _lut_202 = SIMD[DType.uint8, 64](40, 0, 62, 42, 0, 0, 0, 61, 40, 35, 44, 43, 34, 0, 0, 0, 0, 0, 39, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 60, 59, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
comptime _lut_203 = SIMD[DType.uint8, 64](0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
comptime _lut_204 = SIMD[DType.uint8, 64](0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
comptime _lut_205 = SIMD[DType.uint8, 64](0, 0, 0, 0, 0, 37, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 31, 30, 30, 0, 0)
comptime _lut_206 = SIMD[DType.uint8, 64](0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 13, 11, 12, 11, 7, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10)
comptime _lut_207 = SIMD[DType.uint8, 64](23, 23, 24, 23, 23, 23, 23, 23, 23, 23, 23, 23, 15, 18, 16, 0, 17, 20, 0, 0, 0, 27, 28, 8, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 26, 21, 5, 32, 0, 23, 0, 0, 6, 0, 0, 1, 0, 0, 0, 0)
comptime _lut_208 = SIMD[DType.uint8, 64](0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10)
comptime _lut_209 = SIMD[DType.uint8, 64](23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1)
comptime _lut_210 = SIMD[DType.uint8, 64](0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1)
comptime _lut_211 = SIMD[DType.uint8, 64](0, 0, 2, 0, 3, 0, 2, 0, 6, 0, 2, 0, 3, 0, 2, 6, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1)
comptime _lut_212 = SIMD[DType.uint8, 64](0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
comptime _lut_213 = SIMD[DType.uint8, 64](0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14)
comptime _lut_214 = SIMD[DType.uint8, 64](36, 36, 36, 36, 36, 36, 36, 33, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)

@always_inline
def _u2_diff(i: UInt8) -> Diff:
    if i == 0:
        return Diff(0, 0, 0, 0, 0, 0, 2, 0)
    elif i == 1:
        return Diff(0, 1, 0, 0, 0, 0, 2, 0)
    elif i == 2:
        return Diff(0, 3, 0, 0, 0, 0, 2, 0)
    elif i == 3:
        return Diff(0, 7, 0, 0, 0, 0, 2, 0)
    elif i == 4:
        return Diff(0, 9, 204, 136, 204, 129, 6, 0)
    elif i == 5:
        return Diff(0, 11, 0, 0, 0, 0, 2, 0)
    elif i == 6:
        return Diff(0, 15, 0, 0, 0, 0, 2, 0)
    elif i == 7:
        return Diff(0, 21, 204, 136, 204, 129, 6, 0)
    elif i == 8:
        return Diff(0, 24, 0, 0, 0, 0, 2, 0)
    elif i == 9:
        return Diff(0, 31, 0, 0, 0, 0, 2, 0)
    elif i == 10:
        return Diff(0, 32, 0, 0, 0, 0, 2, 0)
    elif i == 11:
        return Diff(0, 37, 0, 0, 0, 0, 2, 0)
    elif i == 12:
        return Diff(0, 39, 0, 0, 0, 0, 2, 0)
    elif i == 13:
        return Diff(0, 42, 0, 0, 0, 0, 2, 0)
    elif i == 14:
        return Diff(0, 48, 0, 0, 0, 0, 2, 0)
    elif i == 15:
        return Diff(1, 0, 0, 0, 0, 0, 2, 0)
    elif i == 16:
        return Diff(1, 1, 0, 0, 0, 0, 2, 0)
    elif i == 17:
        return Diff(1, 2, 0, 0, 0, 0, 2, 0)
    elif i == 18:
        return Diff(1, 3, 0, 0, 0, 0, 2, 0)
    elif i == 19:
        return Diff(1, 8, 0, 0, 0, 0, 2, 0)
    elif i == 20:
        return Diff(1, 9, 0, 0, 0, 0, 2, 0)
    elif i == 21:
        return Diff(1, 16, 0, 0, 0, 0, 2, 0)
    elif i == 22:
        return Diff(1, 19, 0, 0, 0, 0, 2, 0)
    elif i == 23:
        return Diff(1, 32, 0, 0, 0, 0, 2, 0)
    elif i == 24:
        return Diff(1, 33, 0, 0, 0, 0, 2, 0)
    elif i == 25:
        return Diff(1, 35, 0, 0, 0, 0, 2, 0)
    elif i == 26:
        return Diff(1, 42, 0, 0, 0, 0, 2, 0)
    elif i == 27:
        return Diff(1, 51, 0, 0, 0, 0, 2, 0)
    elif i == 28:
        return Diff(1, 54, 0, 0, 0, 0, 2, 0)
    elif i == 29:
        return Diff(1, 63, 0, 0, 0, 0, 2, 0)
    elif i == 30:
        return Diff(2, 2, 0, 0, 0, 0, 2, 0)
    elif i == 31:
        return Diff(2, 6, 0, 0, 0, 0, 2, 0)
    elif i == 32:
        return Diff(2, 12, 0, 0, 0, 0, 2, 0)
    elif i == 33:
        return Diff(2, 50, 213, 146, 0, 0, 4, 0)
    elif i == 34:
        return Diff(3, 9, 0, 0, 0, 0, 2, 0)
    elif i == 35:
        return Diff(3, 13, 0, 0, 0, 0, 2, 0)
    elif i == 36:
        return Diff(3, 16, 0, 0, 0, 0, 2, 0)
    elif i == 37:
        return Diff(3, 28, 0, 0, 0, 0, 2, 0)
    elif i == 38:
        return Diff(6, 7, 0, 0, 0, 0, 2, 0)
    elif i == 39:
        return Diff(12, 37, 0, 0, 0, 0, 2, 0)
    elif i == 40:
        return Diff(12, 38, 0, 0, 0, 0, 2, 0)
    elif i == 41:
        return Diff(12, 41, 0, 0, 0, 0, 2, 0)
    elif i == 42:
        return Diff(12, 42, 0, 0, 0, 0, 2, 0)
    elif i == 43:
        return Diff(12, 57, 0, 0, 0, 0, 2, 0)
    elif i == 44:
        return Diff(12, 59, 0, 0, 0, 0, 2, 0)
    elif i == 45:
        return Diff(14, 39, 0, 0, 0, 0, 2, 0)
    elif i == 46:
        return Diff(14, 62, 0, 0, 0, 0, 2, 0)
    elif i == 47:
        return Diff(15, 3, 0, 0, 0, 0, 2, 0)
    elif i == 48:
        return Diff(15, 11, 0, 0, 0, 0, 2, 0)
    elif i == 49:
        return Diff(15, 18, 0, 0, 0, 0, 2, 0)
    elif i == 50:
        return Diff(15, 22, 0, 0, 0, 0, 2, 0)
    elif i == 51:
        return Diff(15, 29, 0, 0, 0, 0, 2, 0)
    elif i == 52:
        return Diff(15, 31, 0, 0, 0, 0, 2, 0)
    elif i == 53:
        return Diff(15, 42, 0, 0, 0, 0, 2, 0)
    elif i == 54:
        return Diff(15, 47, 0, 0, 0, 0, 2, 0)
    elif i == 55:
        return Diff(15, 51, 0, 0, 0, 0, 2, 0)
    elif i == 56:
        return Diff(15, 53, 78, 0, 0, 0, 3, 0)
    elif i == 57:
        return Diff(15, 55, 0, 0, 0, 0, 2, 0)
    elif i == 58:
        return Diff(15, 63, 0, 0, 0, 0, 2, 0)
    elif i == 59:
        return Diff(32, 0, 176, 0, 0, 0, 3, 0)
    elif i == 60:
        return Diff(32, 3, 178, 0, 0, 0, 3, 0)
    elif i == 61:
        return Diff(32, 25, 177, 0, 0, 0, 3, 0)
    elif i == 62:
        return Diff(32, 29, 133, 0, 0, 0, 3, 0)
    elif i == 63:
        return Diff(35, 2, 171, 0, 0, 0, 3, 0)
    elif i == 64:
        return Diff(35, 50, 173, 0, 0, 0, 3, 0)
    elif i == 65:
        return Diff(35, 52, 174, 0, 0, 0, 3, 0)
    elif i == 66:
        return Diff(35, 56, 170, 0, 0, 0, 3, 0)
    elif i == 67:
        return Diff(35, 59, 141, 0, 0, 0, 3, 0)
    elif i == 68:
        return Diff(35, 63, 172, 0, 0, 0, 3, 0)
    elif i == 69:
        return Diff(42, 14, 190, 0, 0, 0, 3, 0)
    elif i == 70:
        return Diff(43, 0, 174, 0, 0, 0, 3, 0)
    elif i == 71:
        return Diff(43, 12, 164, 0, 0, 0, 3, 0)
    elif i == 72:
        return Diff(43, 26, 162, 0, 0, 0, 3, 0)
    elif i == 73:
        return Diff(43, 32, 173, 0, 0, 0, 3, 0)
    elif i == 74:
        return Diff(43, 33, 175, 0, 0, 0, 3, 0)
    elif i == 75:
        return Diff(43, 35, 176, 0, 0, 0, 3, 0)
    elif i == 76:
        return Diff(43, 49, 191, 0, 0, 0, 3, 0)
    elif i == 77:
        return Diff(141, 0, 0, 0, 0, 0, 1, 0)
    elif i == 78:
        return Diff(141, 124, 140, 0, 0, 0, 3, 0)
    elif i == 79:
        return Diff(144, 204, 0, 0, 0, 0, 2, 0)
    elif i == 80:
        return Diff(150, 0, 0, 0, 0, 0, 1, 0)
    return Diff(0, 0, 0, 0, 0, 0, 2, 0)

@always_inline
def _to_upper(a: UInt8, b: UInt8) -> Diff:
    """Two-byte uppercase: per-a SIMD lookup, no per-byte branches."""
    var j = Int(b) - 128
    if a == 194:
        return _u2_diff(_lut_194[j])
    elif a == 195:
        return _u2_diff(_lut_195[j])
    elif a == 196:
        return _u2_diff(_lut_196[j])
    elif a == 197:
        return _u2_diff(_lut_197[j])
    elif a == 198:
        return _u2_diff(_lut_198[j])
    elif a == 199:
        return _u2_diff(_lut_199[j])
    elif a == 200:
        return _u2_diff(_lut_200[j])
    elif a == 201:
        return _u2_diff(_lut_201[j])
    elif a == 202:
        return _u2_diff(_lut_202[j])
    elif a == 203:
        return _u2_diff(_lut_203[j])
    elif a == 204:
        return _u2_diff(_lut_204[j])
    elif a == 205:
        return _u2_diff(_lut_205[j])
    elif a == 206:
        return _u2_diff(_lut_206[j])
    elif a == 207:
        return _u2_diff(_lut_207[j])
    elif a == 208:
        return _u2_diff(_lut_208[j])
    elif a == 209:
        return _u2_diff(_lut_209[j])
    elif a == 210:
        return _u2_diff(_lut_210[j])
    elif a == 211:
        return _u2_diff(_lut_211[j])
    elif a == 212:
        return _u2_diff(_lut_212[j])
    elif a == 213:
        return _u2_diff(_lut_213[j])
    elif a == 214:
        return _u2_diff(_lut_214[j])
    return Diff(0, 0, 0, 0, 0, 0, 2, 0)


@always_inline
def _to_upper(a: UInt8, b: UInt8, c: UInt8) -> Diff:
    """Three-byte uppercase XOR decision tree."""
    if a == 225:
        if b == 143 and c >= 184 and c <= 189:
            return Diff(0, 0, 8, 0, 0, 0, 3, 0)
        elif b == 178:
            if c == 128:
                return Diff(49, 32, 0, 0, 0, 0, 2, 0)
            elif c == 129:
                return Diff(49, 38, 0, 0, 0, 0, 2, 0)
            elif c == 130:
                return Diff(49, 44, 0, 0, 0, 0, 2, 0)
            elif c == 131:
                return Diff(49, 19, 0, 0, 0, 0, 2, 0)
            elif c == 132:
                return Diff(49, 16, 0, 0, 0, 0, 2, 0)
            elif c == 133:
                return Diff(49, 16, 0, 0, 0, 0, 2, 0)
            elif c == 134:
                return Diff(49, 24, 0, 0, 0, 0, 2, 0)
            elif c == 135:
                return Diff(48, 16, 0, 0, 0, 0, 2, 0)
            elif c == 136:
                return Diff(11, 43, 2, 0, 0, 0, 3, 0)
        elif b == 181:
            if c == 185:
                return Diff(11, 40, 4, 0, 0, 0, 3, 0)
            elif c == 189:
                return Diff(3, 4, 30, 0, 0, 0, 3, 0)
        elif b == 182 and c == 142:
            return Diff(11, 41, 8, 0, 0, 0, 3, 0)
        elif b == 184 and c >= 129 and c <= 191 and c & 1 == 1:
            return Diff(0, 0, 1, 0, 0, 0, 3, 0)
        elif b == 185 and c >= 129 and c <= 191 and c & 1 == 1:
            return Diff(0, 0, 1, 0, 0, 0, 3, 0)
        elif b == 186:
            if c >= 129 and c <= 149 and c & 1 == 1:
                return Diff(0, 0, 1, 0, 0, 0, 3, 0)
            elif c == 150:
                return Diff(169, 118, 39, 0, 0, 0, 3, 0)
            elif c == 151:
                return Diff(181, 118, 31, 0, 0, 0, 3, 0)
            elif c == 152:
                return Diff(182, 118, 18, 0, 0, 0, 3, 0)
            elif c == 153:
                return Diff(184, 118, 19, 0, 0, 0, 3, 0)
            elif c == 154:
                return Diff(160, 112, 36, 0, 0, 0, 3, 0)
            elif c == 155:
                return Diff(0, 3, 59, 0, 0, 0, 3, 0)
            elif c >= 161 and c <= 191 and c & 1 == 1:
                return Diff(0, 0, 1, 0, 0, 0, 3, 0)
        elif b == 187 and c >= 129 and c <= 191 and c & 1 == 1:
            return Diff(0, 0, 1, 0, 0, 0, 3, 0)
        elif b == 188 and ((c >= 128 and c <= 135) or (c >= 144 and c <= 149) or (c >= 160 and c <= 167) or (c >= 176 and c <= 183)):
            return Diff(0, 0, 8, 0, 0, 0, 3, 0)
        elif b == 189:
            if c >= 128 and c <= 133:
                return Diff(0, 0, 8, 0, 0, 0, 3, 0)
            elif c == 144:
                return Diff(47, 24, 92, 147, 0, 0, 4, 0)
            elif c >= 145 and c <= 151 and c & 1 == 1:
                return Diff(0, 0, 8, 0, 0, 0, 3, 0)
            elif c == 146:
                return Diff(47, 24, 94, 147, 204, 128, 6, 0)
            elif c == 148:
                return Diff(47, 24, 88, 147, 204, 129, 6, 0)
            elif c == 150:
                return Diff(47, 24, 90, 147, 205, 130, 6, 0)
            elif c >= 160 and c <= 167:
                return Diff(0, 0, 8, 0, 0, 0, 3, 0)
            elif c == 176:
                return Diff(0, 3, 10, 0, 0, 0, 3, 0)
            elif c == 177:
                return Diff(0, 3, 10, 0, 0, 0, 3, 0)
            elif c == 178:
                return Diff(0, 2, 58, 0, 0, 0, 3, 0)
            elif c == 179:
                return Diff(0, 2, 58, 0, 0, 0, 3, 0)
            elif c == 180:
                return Diff(0, 2, 62, 0, 0, 0, 3, 0)
            elif c == 181:
                return Diff(0, 2, 62, 0, 0, 0, 3, 0)
            elif c == 182:
                return Diff(0, 2, 44, 0, 0, 0, 3, 0)
            elif c == 183:
                return Diff(0, 2, 44, 0, 0, 0, 3, 0)
            elif c == 184:
                return Diff(0, 2, 0, 0, 0, 0, 3, 0)
            elif c == 185:
                return Diff(0, 2, 0, 0, 0, 0, 3, 0)
            elif c == 186:
                return Diff(0, 2, 16, 0, 0, 0, 3, 0)
            elif c == 187:
                return Diff(0, 2, 16, 0, 0, 0, 3, 0)
            elif c == 188:
                return Diff(0, 2, 6, 0, 0, 0, 3, 0)
            elif c == 189:
                return Diff(0, 2, 6, 0, 0, 0, 3, 0)
        elif b == 190:
            if c >= 128 and c <= 135:
                return Diff(0, 2, 8, 206, 153, 0, 5, 0)
            elif c >= 136 and c <= 143:
                return Diff(0, 2, 0, 206, 153, 0, 5, 0)
            elif c >= 144 and c <= 151:
                return Diff(0, 2, 56, 206, 153, 0, 5, 0)
            elif c >= 152 and c <= 159:
                return Diff(0, 2, 48, 206, 153, 0, 5, 0)
            elif c >= 160 and c <= 167:
                return Diff(0, 3, 8, 206, 153, 0, 5, 0)
            elif c >= 168 and c <= 175:
                return Diff(0, 3, 0, 206, 153, 0, 5, 0)
            elif c == 176:
                return Diff(0, 0, 8, 0, 0, 0, 3, 0)
            elif c == 177:
                return Diff(0, 0, 8, 0, 0, 0, 3, 0)
            elif c == 178:
                return Diff(0, 0, 8, 206, 153, 0, 5, 0)
            elif c == 179:
                return Diff(47, 47, 125, 153, 0, 0, 4, 0)
            elif c == 180:
                return Diff(47, 56, 122, 153, 0, 0, 4, 0)
            elif c == 182:
                return Diff(47, 47, 123, 130, 0, 0, 4, 0)
            elif c == 183:
                return Diff(47, 47, 122, 130, 206, 153, 6, 0)
            elif c == 188:
                return Diff(47, 47, 114, 153, 0, 0, 4, 0)
            elif c == 190:
                return Diff(47, 39, 0, 0, 0, 0, 2, 0)
        elif b == 191:
            if c == 130:
                return Diff(0, 0, 8, 206, 153, 0, 5, 0)
            elif c == 131:
                return Diff(47, 40, 77, 153, 0, 0, 4, 0)
            elif c == 132:
                return Diff(47, 54, 74, 153, 0, 0, 4, 0)
            elif c == 134:
                return Diff(47, 40, 75, 130, 0, 0, 4, 0)
            elif c == 135:
                return Diff(47, 40, 74, 130, 206, 153, 6, 0)
            elif c == 140:
                return Diff(47, 40, 66, 153, 0, 0, 4, 0)
            elif c == 144:
                return Diff(0, 0, 8, 0, 0, 0, 3, 0)
            elif c == 145:
                return Diff(0, 0, 8, 0, 0, 0, 3, 0)
            elif c == 146:
                return Diff(47, 38, 94, 136, 204, 128, 6, 0)
            elif c == 147:
                return Diff(47, 38, 95, 136, 204, 129, 6, 0)
            elif c == 150:
                return Diff(47, 38, 91, 130, 0, 0, 4, 0)
            elif c == 151:
                return Diff(47, 38, 91, 136, 205, 130, 6, 0)
            elif c == 160:
                return Diff(0, 0, 8, 0, 0, 0, 3, 0)
            elif c == 161:
                return Diff(0, 0, 8, 0, 0, 0, 3, 0)
            elif c == 162:
                return Diff(47, 26, 110, 136, 204, 128, 6, 0)
            elif c == 163:
                return Diff(47, 26, 111, 136, 204, 129, 6, 0)
            elif c == 164:
                return Diff(47, 30, 104, 147, 0, 0, 4, 0)
            elif c == 165:
                return Diff(0, 0, 9, 0, 0, 0, 3, 0)
            elif c == 166:
                return Diff(47, 26, 107, 130, 0, 0, 4, 0)
            elif c == 167:
                return Diff(47, 26, 107, 136, 205, 130, 6, 0)
            elif c == 178:
                return Diff(0, 0, 8, 206, 153, 0, 5, 0)
            elif c == 179:
                return Diff(47, 22, 125, 153, 0, 0, 4, 0)
            elif c == 180:
                return Diff(47, 48, 122, 153, 0, 0, 4, 0)
            elif c == 182:
                return Diff(47, 22, 123, 130, 0, 0, 4, 0)
            elif c == 183:
                return Diff(47, 22, 122, 130, 206, 153, 6, 0)
            elif c == 188:
                return Diff(47, 22, 114, 153, 0, 0, 4, 0)
    elif a == 226:
        if b == 133:
            if c == 142:
                return Diff(0, 1, 60, 0, 0, 0, 3, 0)
            elif c >= 176 and c <= 191:
                return Diff(0, 0, 16, 0, 0, 0, 3, 0)
        elif b == 134 and c == 132:
            return Diff(0, 0, 7, 0, 0, 0, 3, 0)
        elif b == 147:
            if c == 144:
                return Diff(0, 1, 38, 0, 0, 0, 3, 0)
            elif c == 145:
                return Diff(0, 1, 38, 0, 0, 0, 3, 0)
            elif c == 146:
                return Diff(0, 1, 42, 0, 0, 0, 3, 0)
            elif c == 147:
                return Diff(0, 1, 42, 0, 0, 0, 3, 0)
            elif c == 148:
                return Diff(0, 1, 46, 0, 0, 0, 3, 0)
            elif c == 149:
                return Diff(0, 1, 46, 0, 0, 0, 3, 0)
            elif c == 150:
                return Diff(0, 1, 42, 0, 0, 0, 3, 0)
            elif c == 151:
                return Diff(0, 1, 42, 0, 0, 0, 3, 0)
            elif c == 152:
                return Diff(0, 1, 38, 0, 0, 0, 3, 0)
            elif c == 153:
                return Diff(0, 1, 38, 0, 0, 0, 3, 0)
            elif c == 154:
                return Diff(0, 0, 26, 0, 0, 0, 3, 0)
            elif c == 155:
                return Diff(0, 0, 26, 0, 0, 0, 3, 0)
            elif c == 156:
                return Diff(0, 0, 30, 0, 0, 0, 3, 0)
            elif c == 157:
                return Diff(0, 0, 30, 0, 0, 0, 3, 0)
            elif c == 158:
                return Diff(0, 0, 26, 0, 0, 0, 3, 0)
            elif c == 159:
                return Diff(0, 0, 26, 0, 0, 0, 3, 0)
            elif c == 160:
                return Diff(0, 0, 38, 0, 0, 0, 3, 0)
            elif c == 161:
                return Diff(0, 0, 38, 0, 0, 0, 3, 0)
            elif c == 162:
                return Diff(0, 0, 42, 0, 0, 0, 3, 0)
            elif c == 163:
                return Diff(0, 0, 42, 0, 0, 0, 3, 0)
            elif c == 164:
                return Diff(0, 0, 46, 0, 0, 0, 3, 0)
            elif c == 165:
                return Diff(0, 0, 46, 0, 0, 0, 3, 0)
            elif c == 166:
                return Diff(0, 0, 42, 0, 0, 0, 3, 0)
            elif c == 167:
                return Diff(0, 0, 42, 0, 0, 0, 3, 0)
            elif c == 168:
                return Diff(0, 0, 38, 0, 0, 0, 3, 0)
            elif c == 169:
                return Diff(0, 0, 38, 0, 0, 0, 3, 0)
        elif b == 176 and c >= 176 and c <= 191:
            return Diff(0, 0, 48, 0, 0, 0, 3, 0)
        elif b == 177:
            if c >= 128 and c <= 143:
                return Diff(0, 1, 16, 0, 0, 0, 3, 0)
            elif c >= 144 and c <= 159:
                return Diff(0, 1, 48, 0, 0, 0, 3, 0)
            elif c == 161:
                return Diff(0, 0, 1, 0, 0, 0, 3, 0)
            elif c == 165:
                return Diff(42, 11, 0, 0, 0, 0, 2, 0)
            elif c == 166:
                return Diff(42, 15, 0, 0, 0, 0, 2, 0)
            elif c == 168:
                return Diff(0, 0, 15, 0, 0, 0, 3, 0)
            elif c == 170:
                return Diff(0, 0, 3, 0, 0, 0, 3, 0)
            elif c == 172:
                return Diff(0, 0, 7, 0, 0, 0, 3, 0)
            elif c == 179:
                return Diff(0, 0, 1, 0, 0, 0, 3, 0)
            elif c == 182:
                return Diff(0, 0, 3, 0, 0, 0, 3, 0)
        elif b == 178 and c >= 129 and c <= 191 and c & 1 == 1:
            return Diff(0, 0, 1, 0, 0, 0, 3, 0)
        elif b == 179:
            if c >= 129 and c <= 163 and c & 1 == 1:
                return Diff(0, 0, 1, 0, 0, 0, 3, 0)
            elif c == 172:
                return Diff(0, 0, 7, 0, 0, 0, 3, 0)
            elif c == 174:
                return Diff(0, 0, 3, 0, 0, 0, 3, 0)
            elif c == 179:
                return Diff(0, 0, 1, 0, 0, 0, 3, 0)
        elif b == 180:
            if c >= 128 and c <= 159:
                return Diff(3, 54, 32, 0, 0, 0, 3, 0)
            elif c >= 160 and c <= 165:
                return Diff(3, 55, 32, 0, 0, 0, 3, 0)
            elif c == 167:
                return Diff(3, 55, 32, 0, 0, 0, 3, 0)
            elif c == 173:
                return Diff(3, 55, 32, 0, 0, 0, 3, 0)
    elif a == 234:
        if b == 153 and c >= 129 and c <= 173 and c & 1 == 1:
            return Diff(0, 0, 1, 0, 0, 0, 3, 0)
        elif b == 154 and c >= 129 and c <= 155 and c & 1 == 1:
            return Diff(0, 0, 1, 0, 0, 0, 3, 0)
        elif b == 156 and ((c >= 163 and c <= 175 and c & 1 == 1) or (c >= 179 and c <= 191 and c & 1 == 1)):
            return Diff(0, 0, 1, 0, 0, 0, 3, 0)
        elif b == 157:
            if c >= 129 and c <= 175 and c & 1 == 1:
                return Diff(0, 0, 1, 0, 0, 0, 3, 0)
            elif c == 186:
                return Diff(0, 0, 3, 0, 0, 0, 3, 0)
            elif c == 188:
                return Diff(0, 0, 7, 0, 0, 0, 3, 0)
            elif c == 191:
                return Diff(0, 0, 1, 0, 0, 0, 3, 0)
        elif b == 158:
            if c >= 129 and c <= 135 and c & 1 == 1:
                return Diff(0, 0, 1, 0, 0, 0, 3, 0)
            elif c == 140:
                return Diff(0, 0, 7, 0, 0, 0, 3, 0)
            elif c == 145:
                return Diff(0, 0, 1, 0, 0, 0, 3, 0)
            elif c == 147:
                return Diff(0, 0, 1, 0, 0, 0, 3, 0)
            elif c == 148:
                return Diff(0, 1, 16, 0, 0, 0, 3, 0)
            elif c >= 151 and c <= 169 and c & 1 == 1:
                return Diff(0, 0, 1, 0, 0, 0, 3, 0)
            elif c >= 181 and c <= 191 and c & 1 == 1:
                return Diff(0, 0, 1, 0, 0, 0, 3, 0)
        elif b == 159:
            if c == 129:
                return Diff(0, 0, 1, 0, 0, 0, 3, 0)
            elif c == 131:
                return Diff(0, 0, 1, 0, 0, 0, 3, 0)
            elif c == 136:
                return Diff(0, 0, 15, 0, 0, 0, 3, 0)
            elif c == 138:
                return Diff(0, 0, 3, 0, 0, 0, 3, 0)
            elif c == 145:
                return Diff(0, 0, 1, 0, 0, 0, 3, 0)
            elif c == 151:
                return Diff(0, 0, 1, 0, 0, 0, 3, 0)
            elif c == 153:
                return Diff(0, 0, 1, 0, 0, 0, 3, 0)
            elif c == 182:
                return Diff(0, 0, 3, 0, 0, 0, 3, 0)
        elif b == 173:
            if c == 147:
                return Diff(0, 51, 32, 0, 0, 0, 3, 0)
            elif c >= 176 and c <= 191:
                return Diff(11, 35, 16, 0, 0, 0, 3, 0)
        elif b == 174:
            if c >= 128 and c <= 143:
                return Diff(11, 32, 48, 0, 0, 0, 3, 0)
            elif c >= 144 and c <= 159:
                return Diff(11, 33, 16, 0, 0, 0, 3, 0)
            elif c >= 160 and c <= 175:
                return Diff(11, 33, 48, 0, 0, 0, 3, 0)
            elif c >= 176 and c <= 191:
                return Diff(11, 33, 16, 0, 0, 0, 3, 0)
    elif a == 239:
        if b == 172:
            if c == 128:
                return Diff(169, 234, 0, 0, 0, 0, 2, 0)
            elif c == 129:
                return Diff(169, 229, 0, 0, 0, 0, 2, 0)
            elif c == 130:
                return Diff(169, 224, 0, 0, 0, 0, 2, 0)
            elif c == 131:
                return Diff(169, 234, 202, 0, 0, 0, 3, 0)
            elif c == 132:
                return Diff(169, 234, 200, 0, 0, 0, 3, 0)
            elif c == 133:
                return Diff(188, 248, 0, 0, 0, 0, 2, 0)
            elif c == 134:
                return Diff(188, 248, 0, 0, 0, 0, 2, 0)
            elif c == 147:
                return Diff(58, 40, 70, 134, 0, 0, 4, 0)
            elif c == 148:
                return Diff(58, 40, 64, 181, 0, 0, 4, 0)
            elif c == 149:
                return Diff(58, 40, 65, 187, 0, 0, 4, 0)
            elif c == 150:
                return Diff(58, 34, 67, 134, 0, 0, 4, 0)
            elif c == 151:
                return Diff(58, 40, 67, 189, 0, 0, 4, 0)
        elif b == 189 and c >= 129 and c <= 154:
            return Diff(0, 1, 32, 0, 0, 0, 3, 0)
    return Diff(0, 0, 0, 0, 0, 0, 3, 0)


@always_inline
def _to_upper(a: UInt8, b: UInt8, c: UInt8, d: UInt8) -> Diff:
    """Four-byte uppercase XOR decision tree."""
    if a == 240:
        if b == 144:
            if c == 144:
                if d >= 168 and d <= 175:
                    return Diff(0, 0, 0, 40, 0, 0, 0, 0)
                elif d >= 176 and d <= 183:
                    return Diff(0, 0, 0, 56, 0, 0, 0, 0)
                elif d >= 184 and d <= 191:
                    return Diff(0, 0, 0, 40, 0, 0, 0, 0)
            elif c == 145:
                if d >= 128 and d <= 135:
                    return Diff(0, 0, 1, 24, 0, 0, 0, 0)
                elif d >= 136 and d <= 143:
                    return Diff(0, 0, 1, 40, 0, 0, 0, 0)
            elif c == 147:
                if d >= 152 and d <= 159:
                    return Diff(0, 0, 1, 40, 0, 0, 0, 0)
                elif d >= 160 and d <= 167:
                    return Diff(0, 0, 1, 24, 0, 0, 0, 0)
                elif d >= 168 and d <= 175:
                    return Diff(0, 0, 0, 40, 0, 0, 0, 0)
                elif d >= 176 and d <= 183:
                    return Diff(0, 0, 0, 56, 0, 0, 0, 0)
                elif d >= 184 and d <= 187:
                    return Diff(0, 0, 0, 40, 0, 0, 0, 0)
            elif c == 150:
                if d == 151:
                    return Diff(0, 0, 3, 39, 0, 0, 0, 0)
                elif d >= 152 and d <= 158 and d & 1 == 0:
                    return Diff(0, 0, 3, 41, 0, 0, 0, 0)
                elif d == 153:
                    return Diff(0, 0, 3, 43, 0, 0, 0, 0)
                elif d == 155:
                    return Diff(0, 0, 3, 47, 0, 0, 0, 0)
                elif d == 157:
                    return Diff(0, 0, 3, 43, 0, 0, 0, 0)
                elif d == 159:
                    return Diff(0, 0, 3, 39, 0, 0, 0, 0)
                elif d == 160:
                    return Diff(0, 0, 3, 25, 0, 0, 0, 0)
                elif d == 161:
                    return Diff(0, 0, 3, 27, 0, 0, 0, 0)
                elif d == 163:
                    return Diff(0, 0, 3, 31, 0, 0, 0, 0)
                elif d == 164:
                    return Diff(0, 0, 3, 25, 0, 0, 0, 0)
                elif d == 165:
                    return Diff(0, 0, 3, 27, 0, 0, 0, 0)
                elif d == 166:
                    return Diff(0, 0, 3, 25, 0, 0, 0, 0)
                elif d == 167:
                    return Diff(0, 0, 0, 39, 0, 0, 0, 0)
                elif d >= 168 and d <= 174 and d & 1 == 0:
                    return Diff(0, 0, 0, 41, 0, 0, 0, 0)
                elif d == 169:
                    return Diff(0, 0, 0, 43, 0, 0, 0, 0)
                elif d == 171:
                    return Diff(0, 0, 0, 47, 0, 0, 0, 0)
                elif d == 173:
                    return Diff(0, 0, 0, 43, 0, 0, 0, 0)
                elif d == 175:
                    return Diff(0, 0, 0, 39, 0, 0, 0, 0)
                elif d == 176:
                    return Diff(0, 0, 0, 57, 0, 0, 0, 0)
                elif d == 177:
                    return Diff(0, 0, 0, 59, 0, 0, 0, 0)
                elif d == 179:
                    return Diff(0, 0, 0, 63, 0, 0, 0, 0)
                elif d == 180:
                    return Diff(0, 0, 0, 57, 0, 0, 0, 0)
                elif d == 181:
                    return Diff(0, 0, 0, 59, 0, 0, 0, 0)
                elif d == 182:
                    return Diff(0, 0, 0, 57, 0, 0, 0, 0)
                elif d == 183:
                    return Diff(0, 0, 0, 39, 0, 0, 0, 0)
                elif d == 184:
                    return Diff(0, 0, 0, 41, 0, 0, 0, 0)
                elif d == 185:
                    return Diff(0, 0, 0, 43, 0, 0, 0, 0)
                elif d == 187:
                    return Diff(0, 0, 0, 47, 0, 0, 0, 0)
                elif d == 188:
                    return Diff(0, 0, 0, 41, 0, 0, 0, 0)
            elif c == 179 and d >= 128 and d <= 178:
                return Diff(0, 0, 1, 0, 0, 0, 0, 0)
        elif b == 145 and c == 163 and d >= 128 and d <= 159:
            return Diff(0, 0, 1, 32, 0, 0, 0, 0)
        elif b == 150 and c == 185 and d >= 160 and d <= 191:
            return Diff(0, 0, 0, 32, 0, 0, 0, 0)
        elif b == 158:
            if c == 164:
                if d == 162:
                    return Diff(0, 0, 0, 34, 0, 0, 0, 0)
                elif d == 163:
                    return Diff(0, 0, 0, 34, 0, 0, 0, 0)
                elif d == 164:
                    return Diff(0, 0, 0, 38, 0, 0, 0, 0)
                elif d == 165:
                    return Diff(0, 0, 0, 38, 0, 0, 0, 0)
                elif d == 166:
                    return Diff(0, 0, 0, 34, 0, 0, 0, 0)
                elif d == 167:
                    return Diff(0, 0, 0, 34, 0, 0, 0, 0)
                elif d == 168:
                    return Diff(0, 0, 0, 46, 0, 0, 0, 0)
                elif d == 169:
                    return Diff(0, 0, 0, 46, 0, 0, 0, 0)
                elif d == 170:
                    return Diff(0, 0, 0, 34, 0, 0, 0, 0)
                elif d == 171:
                    return Diff(0, 0, 0, 34, 0, 0, 0, 0)
                elif d == 172:
                    return Diff(0, 0, 0, 38, 0, 0, 0, 0)
                elif d == 173:
                    return Diff(0, 0, 0, 38, 0, 0, 0, 0)
                elif d == 174:
                    return Diff(0, 0, 0, 34, 0, 0, 0, 0)
                elif d == 175:
                    return Diff(0, 0, 0, 34, 0, 0, 0, 0)
                elif d == 176:
                    return Diff(0, 0, 0, 62, 0, 0, 0, 0)
                elif d == 177:
                    return Diff(0, 0, 0, 62, 0, 0, 0, 0)
                elif d == 178:
                    return Diff(0, 0, 0, 34, 0, 0, 0, 0)
                elif d == 179:
                    return Diff(0, 0, 0, 34, 0, 0, 0, 0)
                elif d == 180:
                    return Diff(0, 0, 0, 38, 0, 0, 0, 0)
                elif d == 181:
                    return Diff(0, 0, 0, 38, 0, 0, 0, 0)
                elif d == 182:
                    return Diff(0, 0, 0, 34, 0, 0, 0, 0)
                elif d == 183:
                    return Diff(0, 0, 0, 34, 0, 0, 0, 0)
                elif d == 184:
                    return Diff(0, 0, 0, 46, 0, 0, 0, 0)
                elif d == 185:
                    return Diff(0, 0, 0, 46, 0, 0, 0, 0)
                elif d == 186:
                    return Diff(0, 0, 0, 34, 0, 0, 0, 0)
                elif d == 187:
                    return Diff(0, 0, 0, 34, 0, 0, 0, 0)
                elif d == 188:
                    return Diff(0, 0, 0, 38, 0, 0, 0, 0)
                elif d == 189:
                    return Diff(0, 0, 0, 38, 0, 0, 0, 0)
                elif d == 190:
                    return Diff(0, 0, 0, 34, 0, 0, 0, 0)
                elif d == 191:
                    return Diff(0, 0, 0, 34, 0, 0, 0, 0)
            elif c == 165:
                if d == 128:
                    return Diff(0, 0, 1, 30, 0, 0, 0, 0)
                elif d == 129:
                    return Diff(0, 0, 1, 30, 0, 0, 0, 0)
                elif d == 130:
                    return Diff(0, 0, 1, 34, 0, 0, 0, 0)
                elif d == 131:
                    return Diff(0, 0, 1, 34, 0, 0, 0, 0)
    return Diff(0, 0, 0, 0, 0, 0, 0, 0)


def upper_utf8(s: String) -> String:
    """Convert a UTF-8 string to uppercase.
    Uses an 8-byte SIMD fast path for ASCII runs, lookup table for 2-byte chars.
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
                    SIMD[DType.uint8, SIMD_WIDTH](32), SIMD[DType.uint8, SIMD_WIDTH](0)
                )
                buf.store(vec ^ delta)
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
            buf[0] = b0 ^ _to_upper(b0)
            buf += 1
            count += 1
        elif char_length == 2:
            var b1 = p[offset + 1]
            var diff = _to_upper(b0, b1)
            var out_len = Int(diff[6])
            buf[0] = b0 ^ diff[0]
            buf[1] = b1 ^ diff[1]
            buf[2] = diff[2]
            buf[3] = diff[3]
            buf[4] = diff[4]
            buf[5] = diff[5]
            buf += out_len
            count += out_len
        elif char_length == 3:
            var b1 = p[offset + 1]
            var b2 = p[offset + 2]
            var diff = _to_upper(b0, b1, b2)
            var out_len = Int(diff[6])
            buf[0] = b0 ^ diff[0]
            buf[1] = b1 ^ diff[1]
            buf[2] = b2 ^ diff[2]
            buf[3] = diff[3]
            buf[4] = diff[4]
            buf[5] = diff[5]
            buf += out_len
            count += out_len
        elif char_length == 4:
            var b1 = p[offset + 1]
            var b2 = p[offset + 2]
            var b3 = p[offset + 3]
            var diff = _to_upper(b0, b1, b2, b3)
            buf[0] = b0 ^ diff[0]
            buf[1] = b1 ^ diff[1]
            buf[2] = b2 ^ diff[2]
            buf[3] = b3 ^ diff[3]
            buf += 4
            count += 4
        offset += char_length
    buf[0] = 0
    result.resize(unsafe_uninit_length=count)
    return result

