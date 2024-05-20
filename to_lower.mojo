from csv import CsvTable

@always_inline
fn _ctlz(val: Int) -> Int:
    return llvm_intrinsic["llvm.ctlz", Int](val, False)

@always_inline("nodebug")
fn _ctlz(val: SIMD) -> __type_of(val):
    return llvm_intrinsic["llvm.ctlz", __type_of(val)](val, False)

@always_inline
fn _to_lower(a: UInt8) -> UInt8:
    '''Branch free lower case for ASCII. Returns value which needs to be added to char.'''
    var lower = a >= 65
    var upper = a <= 90
    return (lower & upper).cast[DType.uint8]() * 32

@always_inline
fn _to_lower(a: UInt8, b:UInt8) -> (Int, Int, Int, Int):
    '''Given two bytes representing a UTF-8 char, returns a quadruple of ints to lower case the char. 
    The first two ints need to be added to given bytes in order to lower case the char.
    There are only two case where a 2 byte upper case char needs to be convereted into 3 bytes lower case char. 
    In this case the third int represents the third byte and the fourth int is 3, where in all other cases it is 2.
    This complication is needed to avoid unnecessary branching for all 2 byte chars.'''
    if a == 195:
        var lower = b >= 128
        var upper = b <= 158
        return ((0), int(lower & upper) * 32, 0, 2)
    elif a == 196:
        if b == 176:
            return ((-91), (-176), 0, 1)
        if b == 191:
            return ((1), (193), 0, 2)
        var lower = b >= 128
        var upper = b <= 174
        var even = b & 1 == 0
        alias tail = SIMD[DType.uint8, 8](UInt8(178), UInt8(180), UInt8(182), UInt8(185), UInt8(187), UInt8(189), UInt8(189), UInt8(189))
        var is_tail = SIMD[DType.bool, 1]((tail == b).reduce_or())
        return ((0), (1) * int(is_tail | (lower & upper & even)), 0, 2)
    elif a == 197:
        if b == 184:
            return ((254), (7), 0, 2)
        alias special = SIMD[DType.uint8, 8](UInt8(129), UInt8(131), UInt8(133), UInt8(135), UInt8(185), UInt8(187), UInt8(189), UInt8(189))
        var is_special = SIMD[DType.bool, 1]((special == b).reduce_or())
        var lower = b >= 138
        var upper = b <= 182
        var even = b & 1 == 0
        return ((0), (1) * int(is_special | (lower & upper & even)), 0, 2)
    elif a == 198:
        if b == 129:
            return ((3), (18), 0, 2)
        alias special_1 = SIMD(
            UInt8(130), UInt8(132), UInt8(135), UInt8(139), 
            UInt8(145), UInt8(152), UInt8(160), UInt8(162), 
            UInt8(164), UInt8(167), UInt8(172), UInt8(175), 
            UInt8(179), UInt8(181), UInt8(184), UInt8(188),
        )
        if (special_1 == b).reduce_or():
            return ((0), (1), 0, 2)
        if b == 134:
            return ((3), (14), 0, 2)
        if b == 137 or b == 138 or b == 147:
            return ((3), (13), 0, 2)
        if b == 142:
            return ((1), (15), 0, 2)
        if b == 143:
            return ((3), (10), 0, 2)
        if b == 144:
            return ((3), (11), 0, 2)
        if b == 148:
            return ((3), (15), 0, 2)
        if b == 150:
            return ((3), (19), 0, 2)
        if b == 151:
            return ((3), (17), 0, 2)
        if b == 156:
            return ((3), (19), 0, 2)
        if b == 157:
            return ((3), (21), 0, 2)
        if b == 159:
            return ((3), (22), 0, 2)
        if b == 166 or b == 169 or b == 174:
            return ((4), (218), 0, 2)
        if b == 177 or b == 178:
            return ((4), (217), 0, 2)
        if b == 183:
            return ((4), (219), 0, 2)
    elif a == 199:
        if b == 132 or b == 135 or b == 138 or b == 177:
            return ((0), (2), 0, 2)
        if b == 182:
            return ((255), (223), 0, 2)
        if b == 183:
            return ((255), (8), 0, 2)
        alias special_1 = SIMD[DType.uint8, 8](
            UInt8(133), UInt8(136), UInt8(178), UInt8(180), 
            UInt8(184), UInt8(186), UInt8(188), UInt8(190),
        )
        var l1 = b >= 139 
        var h1 = b <= 155
        var odd = b & 1 == 1
        var l2 = b >= 158
        var h2 = b <= 174
        var is_special = SIMD[DType.bool, 1]((special_1 == b).reduce_or())
        return ((0), (1) * int(is_special | (l1 & h1 & odd) | (l2 & h2 & ~odd)), 0, 2)
    elif a == 200:
        if b == 186:
            return ((26), (-9), 165, 3)
        if b == 189:
            return ((254), (221), 0, 2)
        if b == 190:
            return ((26), (243), 166, 3)
        if b == 160: # order of if experession is important as it is in range 128 ... 178
            return ((254), (254), 0, 2)
        var l1 = b >= 128
        var h1 = b <= 178
        var even = b & 1 == 0
        var is_special = (b == 187)
        return ((0), (1) * int(is_special | (l1 & h1 & even)), 0, 2)
    elif a == 201:
        if b == 131:
            return ((253), (253), 0, 2)
        if b == 132:
            return ((1), (5), 0, 2)
        if b == 133:
            return ((1), (7), 0, 2)
        alias special_1 = SIMD[DType.uint8, 8](
            UInt8(129), UInt8(134), UInt8(136), UInt8(138), 
            UInt8(140), UInt8(142), UInt8(142), UInt8(142),
        )
        return ((0), (1) * int(SIMD[DType.uint8, 1]((special_1 == b).reduce_or())), 0, 2)
    elif a == 205:
        if b == 176 or b == 178 or b == 182:
            return ((0), (1), 0, 2)
        if b == 191:
            return ((2), (244), 0, 2)
    elif a == 206:
        if b == 134:
            return (0, 38, 0, 2)
        if b == 136 or b == 137 or b == 138:
            return (0, 37, 0, 2)
        if b == 140:
            return (1, 0, 0, 2)
        if b == 142 or b == 143:
            return (1, 255, 0, 2)
        if b >= 145 and b <= 159:
            return (0, 32, 0, 2)
        if b >= 160 and b <= 171:
            return (1, 224, 0, 2)
    elif a == 207:
        if b == 143:
            return (0, 8, 0, 2)
        if b == 180:
            return (255, 4, 0, 2)
        if b == 185:
            return (0, 249, 0, 2)
        if b == 189 or b == 190 or b == 191:
            return (254, 254, 0, 2)
        var l1 = b >= 152
        var h1 = b <= 174
        var even = b & 1 == 0
        var is_special = (b == 183 or b == 186)
        return (0, 1 * int(is_special or (l1 & h1 & even)), 0, 2)
    elif a == 208:
        var l1 = b >= 128
        var h1 = b <= 143
        var l2 = b >= 144
        var h2 = b <= 159
        var l3 = b >= 160
        var h3 = b <= 175
        return (
            1 * int((l1 & h1) | (l3 & h3)), 
            16 * int(l1 & h1) + 32 * int(l2 & h2) + 224 * int(l3 & h3), 
            0, 
            2,
        )
    elif a == 209:
        var l1 = b >= 160
        var h1 = b <= 190
        var even = b & 1 == 0
        return (0, 1 * int(l1 & h1 & even), 0, 2)
    elif a == 210:
        var l1 = b >= 138
        var h1 = b <= 190
        var even = b & 1 == 0
        return (0, 1 * int((b == UInt8(128)) | (l1 & h1 & even)), 0, 2)
    elif a == 211:
        if b == 128:
            return ((0), (15), 0, 2)
        var l1 = b >= 129
        var h1 = b <= 141
        var odd = b & 1 == 1
        var l2 = b >= 144
        var h2 = b <= 190
        return (0, 1 * int((l1 & h1 & odd) | (l2 & h2 & ~odd)), 0, 2)
    elif a == 212:
        var l1 = b >= 128
        var h1 = b <= 174
        var even = b & 1 == 0
        var l2 = b >= 177
        var h2 = b <= 191
        var g1 = int(l1 & h1 & even)
        var g2 = int(l2 & h2)
        return (
            1 * g2,
            1 * g1 + 240 * g2, 
            0, 
            2
        )
    elif a == 213:
        var l1 = b >= 128
        var h1 = b <= 143
        var l2 = b >= 144
        var h2 = b <= 150
        var g1 = int(l1 & h1)
        var g2 = int(l2 & h2)
        return (
            1 * g2,
            48 * g1 + 240 * g2, 
            0, 
            2
        )
    return (0, 0, 0, 2)

@always_inline
fn _to_lower(a: UInt8, b:UInt8, c: UInt8) -> (Int, Int, Int, Int):
    '''Given three bytes representing a UTF-8 char, returns a quadruple of ints to lower case the char. 
    The first three ints need to be added to given bytes in order to lower case the char.
    There are multiple case where a 3 byte upper case char needs to be convereted into 2 or even 1 byte lower case char. 
    In this case the fourth int is set to 1 or 2, where in all other cases it is 3.
    This complication is needed to avoid unnecessary branching.'''
    if a == 225:
        if b == 130 and c >= 160 and c <= 191:
            return (1, 50, -32, 3)
        elif b == 131 and ((c >= 128 and c <= 133) or c == 135 or c == 141):
            return (1, 49, 32, 3)
        elif b == 142:
            if c >= 160 and c <= 175:
                return (9, 31, 16, 3)
            if c>= 176 and c <= 191:
                return (9, 32, -48, 3)
        elif b == 143:
            if c >= 128 and c <= 175:
                return (9, 31, 16, 3)
            if c >= 176 and c <= 181:
                return (0, 0, 8, 3)
        elif b == 178 and c >= 144 and c <= 191:
            return (0, -47, 0, 3)
        elif b == 186 and c == 158:
            return (-30, -27, -158, 2)
        elif (b >= 184 and b <= 187) and c >= 128 and c <= 190 and c & 1 == 0:
            return (0, 0, 1, 3)
        elif b == 188:
            if (c >= 136 and c <= 143) or (c >= 152 and c <= 157) or (c >= 168 and c <= 175) or (c >= 184 and c <= 191):
                return (0, 0, -8, 3)
        elif b == 189:
            if (c >= 136 and c <= 141) or (c == 153 or c == 155 or c == 157 or c == 159) or (c >= 168 and c <= 175):
                return (0, 0, -8, 3)
        elif b == 190:
            if (c >= 136 and c <= 143) or (c >= 152 and c <= 159) or (c >= 168 and c <= 175) or (c >= 184 and c <= 185):
                return (0, 0, -8, 3)
            if c == 186 or c == 187:
                return (0, -1, -10, 3)
            if c == 188:
                return (0, 0, -9, 3)
        elif b == 191:
            if c >= 136 and c <= 139:
                return (0, -2, 42, 3)
            if c == 140 or c == 188:
                return (0, 0, -9, 3)
            if c == 152 or c == 153 or c == 168 or c == 169:
                return (0, 0, -8, 3)
            if c == 154 or c == 155:
                return (0, -2, 28, 3)
            if c == 170 or c == 171:
                return (0, -2, 16, 3)
            if c == 172:
                return (0, 0, -7, 3)
            if c == 184 or c == 185:
                return (0, -2, 0, 3)
            if c == 186 or c == 187:
                return (0, -2, 2, 3)
    elif a == 226:
        if b == 132:
            if c == 166:
                return (-19, 5, -166, 2)
            if c == 170:
                return (-119, -132, -170, 1)
            if c == 171:
                return (-31, 33, -171, 2)
            if c == 178:
                return (0, 1, -36, 3)
        elif b == 133 and c >= 160 and c <= 175:
            return (0, 0, 16, 3)
        elif b == 134 and c == 131:
            return (0, 0, 1, 3)
        elif b == 146 and c >= 182 and c <= 191:
            return (0, 1, -38, 3)
        elif b == 147 and c >= 128 and c <= 143:
            return (0, 0, 26, 3)
        elif b == 176:
            if c >= 128 and c <= 143:
                return (0, 0, 48, 3)
            if c >= 144 and c <= 175:
                return (0, 1, -16, 3)
        elif b == 177:
            if c == 160 or c == 167 or c == 169 or c == 171 or c == 178 or c == 181:
                return (0, 0, 1, 3)
            if c == 162:
                return (-25, -6, -162, 2)
            if c == 163:
                return (-1, 4, 26, 3)
            if c == 164:
                return (-25, 12, -164, 2)
            if c == 173:
                return (-25, -32, -173, 2)
            if c == 174:
                return (-25, 0, -174, 2)
            if c == 175:
                return (-25, -33, -175, 2)
            if c == 176:
                return (-25, -31, -176, 2)
            if c == 190:
                return (-26, 14, -190, 2)
            if c == 191:
                return (-25, -49, -191, 2)
        elif b == 178 and c >= 128 and c <= 190 and c & 1 == 0:
            return (0, 0, 1, 3)
        elif b == 179 and (c >= 128 and c <= 162 and c & 1 == 0 or c == 171 or c == 173 or c == 178):
            return (0, 0, 1, 3)
    elif a == 234:
        if b == 153 and c >= 128 and c <= 172 and c & 1 == 0:
            return (0, 0, 1, 3)
        elif b == 154 and c >= 128 and c <= 154 and c & 1 == 0:
            return (0, 0, 1, 3)
        elif b == 156 and c >= 162 and c <= 190 and c & 1 == 0:
            return (0, 0, 1, 3)
        elif b == 157:
            if c >= 128 and c <= 174 and c & 1 == 0 or c == 185 or c == 187 or c == 190:
                return (0, 0, 1, 3)
            if c == 189:
                return (-9, 24, -4, 3)
        elif b == 158:
            if (c >= 128 and c <= 134 or c >= 144 and c <= 168 or c >= 180 and c <= 190) and c & 1 == 0 or c == 139:
                return (0, 0, 1, 3)
            if c == 141:
                return (-33, 7, -141, 2)
            if c == 170:
                return (-33, 8, -170, 2)
            if c == 171:
                return (-33, -2, -171, 2)
            if c == 172:
                return (-33, 3, -172, 2)
            if c == 173:
                return (-33, 14, -173, 2)
            if c == 174:
                return (-33, 12, -174, 2)
            if c == 176:
                return (-32, 0, -176, 2)
            if c == 177:
                return (-32, -23, -177, 2)
            if c == 178:
                return (-32, -1, -178, 2)
            if c == 179:
                return (0, 15, -32, 3)
        elif b == 159:
            if c == 128 or c == 130 or c == 135 or c == 137 or c == 144 or c == 150 or c == 152 or c == 181:
                return (0, 0, 1, 3)
            if c == 132:
                return (0, -1, 16, 3)
            if c == 133:
                return (-32, -29, -133, 2)
            if c == 134:
                return (-9, 23, 8, 3)
    elif a == 239 and b == 188 and c >= 161 and c <= 186:
            return (0, 1, -32, 3)
    return (0, 0, 0, 3)

@always_inline
fn _to_lower(a: UInt8, b:UInt8, c: UInt8, d: UInt8) -> (Int, Int, Int, Int):
    '''Given three bytes representing a UTF-8 char, returns a quadruple of ints to lower case the char. 
    The returned ints need to be added to given bytes in order to lower case the char.'''
    if a == 240:
        if b == 144:
            if c == 144:
                if d >= 128 and d <= 151:
                    return (0, 0, 0, 40)
                if d >= 152 and d <= 167:
                    return (0, 0, 1, -24)
            if c == 146 and d >= 176 and d <= 191:
                return (0, 0, 1, -24)
            if c == 147 and d >= 128 and d <= 147:
                return (0, 0, 0, 40)
            if c == 149 and d >= 176 and d <= 191:
                return (0, 0, 1, -25)
            if c == 150 and d >= 128 and d <= 149:
                return (0, 0, 0, 39)
            if c == 178 and d >= 128 and d <= 178:
                return (0, 0, 1, 0)
        elif b == 145 and c == 162 and d >= 160 and d <= 191:
            return (0, 0, 1, -32)
        elif b == 150 and c == 185 and d >= 128 and d <= 159:
            return (0, 0, 0, 32)
        elif b == 158 and c == 164:
            if d >= 128 and d <= 157:
                return (0, 0, 0, 34)
            if d >= 158 and d <= 161:
                return (0, 0, 1, -30)
    return (0, 0, 0, 0)

# fn to_lower(inout s: String):
#     var length = len(s)
#     var p = s._as_ptr().bitcast[DType.uint8]()
#     while length > 0:
#         var char_length = ((p.load() >> 7 == 0).cast[DType.uint8]() * 1 + _ctlz(~p.load()))
#         if char_length == 1:
#             p[0] += _to_lower(p[0])
#         elif char_length == 2:
#             var diff = _to_lower(p[0], p[1])
#             p[0] = p[0] + diff.get[0, Int]()
#             p[1] = p[1] + diff.get[1, Int]()
#         elif char_length == 3:
#             var diff = _to_lower(p[0], p[1], p[2])
#             p[0] += diff.get[0, Int]()
#             p[1] += diff.get[1, Int]()
#             p[2] += diff.get[2, Int]()
#         elif char_length == 4:
#             var diff = _to_lower(p[0], p[1], p[2], p[3])
#             p[0] += diff.get[0, Int]()
#             p[1] += diff.get[1, Int]()
#             p[2] += diff.get[2, Int]()
#             p[3] += diff.get[3, Int]()
#         p += char_length
#         length -= char_length

fn lower_utf8(p: DTypePointer[DType.uint8], bytes: Int) -> String:
    '''Given a pointer to the utf-8 encoded string buffer and it's size in bytes, return a new string, where all the chars are in lower case.'''
    var result = DTypePointer[DType.uint8].alloc(bytes // 2 * 3 + 1)
    var added_bytes = 0
    var cp = p
    var rest_bytes = bytes
    var resultp = result
    while rest_bytes > 0:
        var char_length = int((cp.load() >> 7 == 0).cast[DType.uint8]() * 1 + _ctlz(~cp.load()))
        if char_length == 1:
            resultp[0] = cp[0] + _to_lower(cp[0])
            added_bytes += 1
        elif char_length == 2:
            var diff = _to_lower(cp[0], cp[1])
            resultp[0] = cp[0] + diff.get[0, Int]()
            resultp[1] = cp[1] + diff.get[1, Int]()
            resultp[2] = diff.get[2, Int]()
            added_bytes += diff.get[3, Int]()
        elif char_length == 3:
            var diff = _to_lower(cp[0], cp[1], cp[2])
            resultp[0] += cp[0] + diff.get[0, Int]()
            resultp[1] += cp[1] + diff.get[1, Int]()
            resultp[2] += cp[2] + diff.get[2, Int]()
            added_bytes += diff.get[3, Int]()
        elif char_length == 4:
            var diff = _to_lower(cp[0], cp[1], cp[2], cp[3])
            resultp[0] = cp[0] + diff.get[0, Int]()
            resultp[1] = cp[1] + diff.get[1, Int]()
            resultp[2] = cp[2] + diff.get[2, Int]()
            resultp[3] = cp[3] + diff.get[3, Int]()
            added_bytes += 4
        cp += char_length
        rest_bytes -= char_length
        resultp = result + added_bytes
    resultp[0] = 0
    return String(result, added_bytes + 1)

fn main() raises:
    with open("to_lower.csv", "r") as f:
        var csv_string = f.read()
        # print(csv_string)
        var table = CsvTable(csv_string)
        for i in range(1, table.row_count()):
            var source = table.get(i, 2)
            var dest = table.get(i, 7)
            var conv = lower_utf8(source.unsafe_uint8_ptr(), len(source))
            if conv != dest:
                print("!!!!", i, table.get(i, 1), source, conv, dest)
