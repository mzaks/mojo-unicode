from std.bit import count_leading_zeros

comptime Diff = SIMD[DType.uint8, 8]


@always_inline
def _to_upper(a: UInt8) -> UInt8:
    """Branch-free ASCII uppercase. Returns XOR mask (32 for a-z, 0 otherwise)."""
    var is_lower = (a >= 97) & (a <= 122)
    return UInt8(is_lower) * 32


@always_inline
def _to_upper(a: UInt8, b: UInt8) -> Diff:
    """Given two bytes of a UTF-8 char, returns XOR masks for uppercasing.
    Returns Diff(xor_byte0, xor_byte1, extra2..5, output_len, 0).
    """
    if a == 194:
        if b == 181:
            return Diff(12, 41, 0, 0, 0, 0, 2, 0)
    elif a == 195:
        if b == 159:
            return Diff(144, 204, 0, 0, 0, 0, 2, 0)
        elif (b >= 160 and b <= 182) or (b >= 184 and b <= 190):
            return Diff(0, 32, 0, 0, 0, 0, 2, 0)
        elif b == 191:
            return Diff(6, 7, 0, 0, 0, 0, 2, 0)
    elif a == 196:
        if (b >= 129 and b <= 175 and b & 1 == 1) or (b >= 179 and b <= 183 and b & 1 == 1):
            return Diff(0, 1, 0, 0, 0, 0, 2, 0)
        elif b == 177:
            return Diff(141, 0, 0, 0, 0, 0, 1, 0)
        elif (b == 186) or (b == 190):
            return Diff(0, 3, 0, 0, 0, 0, 2, 0)
        elif b == 188:
            return Diff(0, 7, 0, 0, 0, 0, 2, 0)
    elif a == 197:
        if b == 128:
            return Diff(1, 63, 0, 0, 0, 0, 2, 0)
        elif (b == 130) or (b == 134) or (b == 186) or (b == 190):
            return Diff(0, 3, 0, 0, 0, 0, 2, 0)
        elif (b == 132) or (b == 188):
            return Diff(0, 7, 0, 0, 0, 0, 2, 0)
        elif b == 136:
            return Diff(0, 15, 0, 0, 0, 0, 2, 0)
        elif b == 137:
            return Diff(15, 53, 78, 0, 0, 0, 3, 0)
        elif b >= 139 and b <= 183 and b & 1 == 1:
            return Diff(0, 1, 0, 0, 0, 0, 2, 0)
        elif b == 191:
            return Diff(150, 0, 0, 0, 0, 0, 1, 0)
    elif a == 198:
        if b == 128:
            return Diff(15, 3, 0, 0, 0, 0, 2, 0)
        elif (b == 131) or (b == 133) or (b == 153) or (b >= 161 and b <= 165 and b & 1 == 1) or (b == 173) or (b == 185) or (b == 189):
            return Diff(0, 1, 0, 0, 0, 0, 2, 0)
        elif (b == 136) or (b == 168):
            return Diff(0, 15, 0, 0, 0, 0, 2, 0)
        elif (b == 140) or (b == 180):
            return Diff(0, 7, 0, 0, 0, 0, 2, 0)
        elif (b == 146) or (b == 182):
            return Diff(0, 3, 0, 0, 0, 0, 2, 0)
        elif b == 149:
            return Diff(1, 35, 0, 0, 0, 0, 2, 0)
        elif b == 154:
            return Diff(14, 39, 0, 0, 0, 0, 2, 0)
        elif b == 158:
            return Diff(14, 62, 0, 0, 0, 0, 2, 0)
        elif b == 176:
            return Diff(0, 31, 0, 0, 0, 0, 2, 0)
        elif b == 191:
            return Diff(1, 8, 0, 0, 0, 0, 2, 0)
    elif a == 199:
        if (b == 132) or (b == 137) or (b == 138) or (b >= 159 and b <= 175 and b & 1 == 1) or (b == 179) or (b == 181) or (b >= 185 and b <= 191 and b & 1 == 1):
            return Diff(0, 1, 0, 0, 0, 0, 2, 0)
        elif (b == 134) or (b == 142) or (b == 146) or (b == 150) or (b == 154) or (b == 177):
            return Diff(0, 3, 0, 0, 0, 0, 2, 0)
        elif (b == 135) or (b == 152):
            return Diff(0, 15, 0, 0, 0, 0, 2, 0)
        elif (b == 140) or (b == 148) or (b == 156):
            return Diff(0, 7, 0, 0, 0, 0, 2, 0)
        elif b == 144:
            return Diff(0, 31, 0, 0, 0, 0, 2, 0)
        elif b == 157:
            return Diff(1, 19, 0, 0, 0, 0, 2, 0)
        elif b == 176:
            return Diff(141, 124, 140, 0, 0, 0, 3, 0)
    elif a == 200:
        if (b >= 129 and b <= 159 and b & 1 == 1) or (b >= 163 and b <= 179 and b & 1 == 1):
            return Diff(0, 1, 0, 0, 0, 0, 2, 0)
        elif b == 188:
            return Diff(0, 7, 0, 0, 0, 0, 2, 0)
        elif b == 191:
            return Diff(42, 14, 190, 0, 0, 0, 3, 0)
    elif a == 201:
        if b == 128:
            return Diff(43, 49, 191, 0, 0, 0, 3, 0)
        elif b == 130:
            return Diff(0, 3, 0, 0, 0, 0, 2, 0)
        elif b >= 135 and b <= 143 and b & 1 == 1:
            return Diff(0, 1, 0, 0, 0, 0, 2, 0)
        elif b == 144:
            return Diff(43, 33, 175, 0, 0, 0, 3, 0)
        elif b == 145:
            return Diff(43, 32, 173, 0, 0, 0, 3, 0)
        elif b == 146:
            return Diff(43, 35, 176, 0, 0, 0, 3, 0)
        elif (b == 147) or (b == 148):
            return Diff(15, 18, 0, 0, 0, 0, 2, 0)
        elif b == 150:
            return Diff(15, 31, 0, 0, 0, 0, 2, 0)
        elif b == 151:
            return Diff(15, 29, 0, 0, 0, 0, 2, 0)
        elif b == 153:
            return Diff(15, 22, 0, 0, 0, 0, 2, 0)
        elif b == 155:
            return Diff(15, 11, 0, 0, 0, 0, 2, 0)
        elif b == 156:
            return Diff(35, 2, 171, 0, 0, 0, 3, 0)
        elif (b == 160) or (b == 175):
            return Diff(15, 51, 0, 0, 0, 0, 2, 0)
        elif b == 161:
            return Diff(35, 63, 172, 0, 0, 0, 3, 0)
        elif b == 163:
            return Diff(15, 55, 0, 0, 0, 0, 2, 0)
        elif b == 165:
            return Diff(35, 59, 141, 0, 0, 0, 3, 0)
        elif b == 166:
            return Diff(35, 56, 170, 0, 0, 0, 3, 0)
        elif (b == 168) or (b == 169):
            return Diff(15, 63, 0, 0, 0, 0, 2, 0)
        elif b == 170:
            return Diff(35, 52, 174, 0, 0, 0, 3, 0)
        elif b == 171:
            return Diff(43, 26, 162, 0, 0, 0, 3, 0)
        elif b == 172:
            return Diff(35, 50, 173, 0, 0, 0, 3, 0)
        elif b == 177:
            return Diff(43, 0, 174, 0, 0, 0, 3, 0)
        elif b == 178:
            return Diff(15, 47, 0, 0, 0, 0, 2, 0)
        elif b == 181:
            return Diff(15, 42, 0, 0, 0, 0, 2, 0)
        elif b == 189:
            return Diff(43, 12, 164, 0, 0, 0, 3, 0)
    elif a == 202:
        if (b == 128) or (b == 136):
            return Diff(12, 38, 0, 0, 0, 0, 2, 0)
        elif b == 130:
            return Diff(32, 29, 133, 0, 0, 0, 3, 0)
        elif b == 131:
            return Diff(12, 42, 0, 0, 0, 0, 2, 0)
        elif b == 135:
            return Diff(32, 25, 177, 0, 0, 0, 3, 0)
        elif b == 137:
            return Diff(3, 13, 0, 0, 0, 0, 2, 0)
        elif b == 138:
            return Diff(12, 59, 0, 0, 0, 0, 2, 0)
        elif b == 139:
            return Diff(12, 57, 0, 0, 0, 0, 2, 0)
        elif b == 140:
            return Diff(3, 9, 0, 0, 0, 0, 2, 0)
        elif b == 146:
            return Diff(12, 37, 0, 0, 0, 0, 2, 0)
        elif b == 157:
            return Diff(32, 3, 178, 0, 0, 0, 3, 0)
        elif b == 158:
            return Diff(32, 0, 176, 0, 0, 0, 3, 0)
    elif a == 205:
        if b == 133:
            return Diff(3, 28, 0, 0, 0, 0, 2, 0)
        elif (b == 177) or (b == 179) or (b == 183):
            return Diff(0, 1, 0, 0, 0, 0, 2, 0)
        elif b == 187:
            return Diff(2, 6, 0, 0, 0, 0, 2, 0)
        elif (b == 188) or (b == 189):
            return Diff(2, 2, 0, 0, 0, 0, 2, 0)
    elif a == 206:
        if b == 144:
            return Diff(0, 9, 204, 136, 204, 129, 6, 0)
        elif b == 172:
            return Diff(0, 42, 0, 0, 0, 0, 2, 0)
        elif (b == 173) or (b == 175):
            return Diff(0, 37, 0, 0, 0, 0, 2, 0)
        elif b == 174:
            return Diff(0, 39, 0, 0, 0, 0, 2, 0)
        elif b == 176:
            return Diff(0, 21, 204, 136, 204, 129, 6, 0)
        elif b >= 177 and b <= 191:
            return Diff(0, 32, 0, 0, 0, 0, 2, 0)
    elif a == 207:
        if (b == 128) or (b == 129) or (b >= 131 and b <= 139) or (b == 181):
            return Diff(1, 32, 0, 0, 0, 0, 2, 0)
        elif b == 130:
            return Diff(1, 33, 0, 0, 0, 0, 2, 0)
        elif b == 140:
            return Diff(1, 0, 0, 0, 0, 0, 2, 0)
        elif b == 141:
            return Diff(1, 3, 0, 0, 0, 0, 2, 0)
        elif b == 142:
            return Diff(1, 1, 0, 0, 0, 0, 2, 0)
        elif b == 144:
            return Diff(1, 2, 0, 0, 0, 0, 2, 0)
        elif b == 145:
            return Diff(1, 9, 0, 0, 0, 0, 2, 0)
        elif b == 149:
            return Diff(1, 51, 0, 0, 0, 0, 2, 0)
        elif b == 150:
            return Diff(1, 54, 0, 0, 0, 0, 2, 0)
        elif b == 151:
            return Diff(0, 24, 0, 0, 0, 0, 2, 0)
        elif (b >= 153 and b <= 175 and b & 1 == 1) or (b == 187):
            return Diff(0, 1, 0, 0, 0, 0, 2, 0)
        elif b == 176:
            return Diff(1, 42, 0, 0, 0, 0, 2, 0)
        elif b == 177:
            return Diff(1, 16, 0, 0, 0, 0, 2, 0)
        elif b == 178:
            return Diff(0, 11, 0, 0, 0, 0, 2, 0)
        elif b == 179:
            return Diff(2, 12, 0, 0, 0, 0, 2, 0)
        elif b == 184:
            return Diff(0, 15, 0, 0, 0, 0, 2, 0)
    elif a == 208:
        if b >= 176 and b <= 191:
            return Diff(0, 32, 0, 0, 0, 0, 2, 0)
    elif a == 209:
        if b >= 128 and b <= 143:
            return Diff(1, 32, 0, 0, 0, 0, 2, 0)
        elif b >= 144 and b <= 159:
            return Diff(1, 16, 0, 0, 0, 0, 2, 0)
        elif b >= 161 and b <= 191 and b & 1 == 1:
            return Diff(0, 1, 0, 0, 0, 0, 2, 0)
    elif a == 210:
        if (b == 129) or (b >= 139 and b <= 191 and b & 1 == 1):
            return Diff(0, 1, 0, 0, 0, 0, 2, 0)
    elif a == 211:
        if (b == 130) or (b == 134) or (b == 138) or (b == 142):
            return Diff(0, 3, 0, 0, 0, 0, 2, 0)
        elif (b == 132) or (b == 140):
            return Diff(0, 7, 0, 0, 0, 0, 2, 0)
        elif (b == 136) or (b == 143):
            return Diff(0, 15, 0, 0, 0, 0, 2, 0)
        elif b >= 145 and b <= 191 and b & 1 == 1:
            return Diff(0, 1, 0, 0, 0, 0, 2, 0)
    elif a == 212:
        if b >= 129 and b <= 175 and b & 1 == 1:
            return Diff(0, 1, 0, 0, 0, 0, 2, 0)
    elif a == 213:
        if b >= 161 and b <= 175:
            return Diff(1, 16, 0, 0, 0, 0, 2, 0)
        elif b >= 176 and b <= 191:
            return Diff(0, 48, 0, 0, 0, 0, 2, 0)
    elif a == 214:
        if b >= 128 and b <= 134:
            return Diff(3, 16, 0, 0, 0, 0, 2, 0)
        elif b == 135:
            return Diff(2, 50, 213, 146, 0, 0, 4, 0)
    return Diff(0, 0, 0, 0, 0, 0, 2, 0)


@always_inline
def _to_upper(a: UInt8, b: UInt8, c: UInt8) -> Diff:
    """Given three bytes of a UTF-8 char, returns XOR masks for uppercasing.
    Returns Diff(xor_byte0, xor_byte1, xor_byte2, extra3..5, output_len, 0).
    """
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
    """Given four bytes of a UTF-8 char, returns XOR masks for uppercasing.
    Returns Diff(xor_byte0, xor_byte1, xor_byte2, xor_byte3, 0, 0, 0, 0).
    """
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
    """Convert a UTF-8 encoded string to uppercase using a decision tree.
    Uses an 8-byte SIMD fast path for aligned runs of pure ASCII.

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
            buf[0] = b0 ^ (Byte((b0 >= 97) & (b0 <= 122)) << 5)
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

