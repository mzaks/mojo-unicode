from std.bit import count_leading_zeros

comptime Diff = SIMD[DType.uint8, 4]


@always_inline
def _to_lower(a: UInt8, b: UInt8) -> Diff:
    """Given two bytes of a UTF-8 char, returns XOR masks for lowercasing.
    Returns Diff(xor_byte0, xor_byte1, extra_byte, output_len).
    """
    if a == 195:
        if (b >= 128 and b <= 150) or (b >= 152 and b <= 158):
            return Diff(0, 32, 0, 2)
    elif a == 196:
        if (b >= 128 and b <= 174 and b & 1 == 0) or (b >= 178 and b <= 182 and b & 1 == 0):
            return Diff(0, 1, 0, 2)
        elif b == 176:
            return Diff(173, 176, 0, 1)
        elif (b == 185) or (b == 189):
            return Diff(0, 3, 0, 2)
        elif b == 187:
            return Diff(0, 7, 0, 2)
        elif b == 191:
            return Diff(1, 63, 0, 2)
    elif a == 197:
        if (b == 129) or (b == 133) or (b == 185) or (b == 189):
            return Diff(0, 3, 0, 2)
        elif (b == 131) or (b == 187):
            return Diff(0, 7, 0, 2)
        elif b == 135:
            return Diff(0, 15, 0, 2)
        elif b >= 138 and b <= 182 and b & 1 == 0:
            return Diff(0, 1, 0, 2)
        elif b == 184:
            return Diff(6, 7, 0, 2)
    elif a == 198:
        if (b == 129) or (b == 134):
            return Diff(15, 18, 0, 2)
        elif (b == 130) or (b == 132) or (b == 152) or (b >= 160 and b <= 164 and b & 1 == 0) or (b == 172) or (b == 184) or (b == 188):
            return Diff(0, 1, 0, 2)
        elif (b == 135) or (b == 167):
            return Diff(0, 15, 0, 2)
        elif b == 137:
            return Diff(15, 31, 0, 2)
        elif b == 138:
            return Diff(15, 29, 0, 2)
        elif (b == 139) or (b == 179):
            return Diff(0, 7, 0, 2)
        elif b == 142:
            return Diff(1, 19, 0, 2)
        elif b == 143:
            return Diff(15, 22, 0, 2)
        elif b == 144:
            return Diff(15, 11, 0, 2)
        elif (b == 145) or (b == 181):
            return Diff(0, 3, 0, 2)
        elif (b == 147) or (b == 156):
            return Diff(15, 51, 0, 2)
        elif b == 148:
            return Diff(15, 55, 0, 2)
        elif (b == 150) or (b == 151):
            return Diff(15, 63, 0, 2)
        elif b == 157:
            return Diff(15, 47, 0, 2)
        elif b == 159:
            return Diff(15, 42, 0, 2)
        elif (b == 166) or (b == 174):
            return Diff(12, 38, 0, 2)
        elif b == 169:
            return Diff(12, 42, 0, 2)
        elif b == 175:
            return Diff(0, 31, 0, 2)
        elif b == 177:
            return Diff(12, 59, 0, 2)
        elif b == 178:
            return Diff(12, 57, 0, 2)
        elif b == 183:
            return Diff(12, 37, 0, 2)
    elif a == 199:
        if (b == 132) or (b == 177):
            return Diff(0, 2, 0, 2)
        elif (b == 133) or (b == 141) or (b == 145) or (b == 149) or (b == 153):
            return Diff(0, 3, 0, 2)
        elif b == 135:
            return Diff(0, 14, 0, 2)
        elif (b == 136) or (b >= 158 and b <= 174 and b & 1 == 0) or (b == 178) or (b == 180) or (b >= 184 and b <= 190 and b & 1 == 0):
            return Diff(0, 1, 0, 2)
        elif b == 138:
            return Diff(0, 6, 0, 2)
        elif (b == 139) or (b == 147) or (b == 155):
            return Diff(0, 7, 0, 2)
        elif b == 143:
            return Diff(0, 31, 0, 2)
        elif b == 151:
            return Diff(0, 15, 0, 2)
        elif b == 182:
            return Diff(1, 35, 0, 2)
        elif b == 183:
            return Diff(1, 8, 0, 2)
    elif a == 200:
        if (b >= 128 and b <= 158 and b & 1 == 0) or (b >= 162 and b <= 178 and b & 1 == 0):
            return Diff(0, 1, 0, 2)
        elif b == 160:
            return Diff(14, 62, 0, 2)
        elif b == 186:
            return Diff(42, 11, 165, 3)
        elif b == 187:
            return Diff(0, 7, 0, 2)
        elif b == 189:
            return Diff(14, 39, 0, 2)
        elif b == 190:
            return Diff(42, 15, 166, 3)
    elif a == 201:
        if b == 129:
            return Diff(0, 3, 0, 2)
        elif b == 131:
            return Diff(15, 3, 0, 2)
        elif b == 132:
            return Diff(3, 13, 0, 2)
        elif b == 133:
            return Diff(3, 9, 0, 2)
        elif b >= 134 and b <= 142 and b & 1 == 0:
            return Diff(0, 1, 0, 2)
    elif a == 205:
        if (b == 176) or (b == 178) or (b == 182):
            return Diff(0, 1, 0, 2)
        elif b == 191:
            return Diff(2, 12, 0, 2)
    elif a == 206:
        if b == 134:
            return Diff(0, 42, 0, 2)
        elif (b == 136) or (b == 138):
            return Diff(0, 37, 0, 2)
        elif b == 137:
            return Diff(0, 39, 0, 2)
        elif b == 140:
            return Diff(1, 0, 0, 2)
        elif b == 142:
            return Diff(1, 3, 0, 2)
        elif b == 143:
            return Diff(1, 1, 0, 2)
        elif b >= 145 and b <= 159:
            return Diff(0, 32, 0, 2)
        elif (b == 160) or (b == 161) or (b >= 163 and b <= 171):
            return Diff(1, 32, 0, 2)
    elif a == 207:
        if b == 143:
            return Diff(0, 24, 0, 2)
        elif (b >= 152 and b <= 174 and b & 1 == 0) or (b == 186):
            return Diff(0, 1, 0, 2)
        elif b == 180:
            return Diff(1, 12, 0, 2)
        elif b == 183:
            return Diff(0, 15, 0, 2)
        elif b == 185:
            return Diff(0, 11, 0, 2)
        elif b == 189:
            return Diff(2, 6, 0, 2)
        elif (b == 190) or (b == 191):
            return Diff(2, 2, 0, 2)
    elif a == 208:
        if b >= 128 and b <= 143:
            return Diff(1, 16, 0, 2)
        elif b >= 144 and b <= 159:
            return Diff(0, 32, 0, 2)
        elif b >= 160 and b <= 175:
            return Diff(1, 32, 0, 2)
    elif a == 209:
        if b >= 160 and b <= 190 and b & 1 == 0:
            return Diff(0, 1, 0, 2)
    elif a == 210:
        if (b == 128) or (b >= 138 and b <= 190 and b & 1 == 0):
            return Diff(0, 1, 0, 2)
    elif a == 211:
        if (b == 128) or (b == 135):
            return Diff(0, 15, 0, 2)
        elif (b == 129) or (b == 133) or (b == 137) or (b == 141):
            return Diff(0, 3, 0, 2)
        elif (b == 131) or (b == 139):
            return Diff(0, 7, 0, 2)
        elif b >= 144 and b <= 190 and b & 1 == 0:
            return Diff(0, 1, 0, 2)
    elif a == 212:
        if b >= 128 and b <= 174 and b & 1 == 0:
            return Diff(0, 1, 0, 2)
        elif b >= 177 and b <= 191:
            return Diff(1, 16, 0, 2)
    elif a == 213:
        if b >= 128 and b <= 143:
            return Diff(0, 48, 0, 2)
        elif b >= 144 and b <= 150:
            return Diff(3, 16, 0, 2)
    return Diff(0, 0, 0, 2)


@always_inline
def _to_lower(a: UInt8, b: UInt8, c: UInt8) -> Diff:
    """Given three bytes of a UTF-8 char, returns XOR masks for lowercasing.
    Returns Diff(xor_byte0, xor_byte1, xor_byte2, output_len).
    """
    if a == 225:
        if b == 130 and c >= 160 and c <= 191:
            return Diff(3, 54, 32, 3)
        elif b == 131 and ((c >= 128 and c <= 133) or (c == 135) or (c == 141)):
            return Diff(3, 55, 32, 3)
        elif b == 142:
            if c >= 160 and c <= 175:
                return Diff(11, 35, 16, 3)
            elif c >= 176 and c <= 191:
                return Diff(11, 32, 48, 3)
        elif b == 143:
            if c >= 128 and c <= 143:
                return Diff(11, 33, 16, 3)
            elif c >= 144 and c <= 159:
                return Diff(11, 33, 48, 3)
            elif c >= 160 and c <= 175:
                return Diff(11, 33, 16, 3)
            elif c >= 176 and c <= 181:
                return Diff(0, 0, 8, 3)
        elif b == 178 and ((c >= 144 and c <= 186) or (c >= 189 and c <= 191)):
            return Diff(0, 49, 0, 3)
        elif b == 184 and c >= 128 and c <= 190 and c & 1 == 0:
            return Diff(0, 0, 1, 3)
        elif b == 185 and c >= 128 and c <= 190 and c & 1 == 0:
            return Diff(0, 0, 1, 3)
        elif b == 186:
            if c >= 128 and c <= 148 and c & 1 == 0:
                return Diff(0, 0, 1, 3)
            elif c == 158:
                return Diff(34, 37, 158, 2)
            elif c >= 160 and c <= 190 and c & 1 == 0:
                return Diff(0, 0, 1, 3)
        elif b == 187 and c >= 128 and c <= 190 and c & 1 == 0:
            return Diff(0, 0, 1, 3)
        elif b == 188 and ((c >= 136 and c <= 143) or (c >= 152 and c <= 157) or (c >= 168 and c <= 175) or (c >= 184 and c <= 191)):
            return Diff(0, 0, 8, 3)
        elif b == 189 and ((c >= 136 and c <= 141) or (c >= 153 and c <= 159 and c & 1 == 1) or (c >= 168 and c <= 175)):
            return Diff(0, 0, 8, 3)
        elif b == 190:
            if c >= 136 and c <= 143:
                return Diff(0, 0, 8, 3)
            elif c >= 152 and c <= 159:
                return Diff(0, 0, 8, 3)
            elif c >= 168 and c <= 175:
                return Diff(0, 0, 8, 3)
            elif c == 184:
                return Diff(0, 0, 8, 3)
            elif c == 185:
                return Diff(0, 0, 8, 3)
            elif c == 186:
                return Diff(0, 3, 10, 3)
            elif c == 187:
                return Diff(0, 3, 10, 3)
            elif c == 188:
                return Diff(0, 0, 15, 3)
        elif b == 191:
            if c == 136:
                return Diff(0, 2, 58, 3)
            elif c == 137:
                return Diff(0, 2, 58, 3)
            elif c == 138:
                return Diff(0, 2, 62, 3)
            elif c == 139:
                return Diff(0, 2, 62, 3)
            elif c == 140:
                return Diff(0, 0, 15, 3)
            elif c == 152:
                return Diff(0, 0, 8, 3)
            elif c == 153:
                return Diff(0, 0, 8, 3)
            elif c == 154:
                return Diff(0, 2, 44, 3)
            elif c == 155:
                return Diff(0, 2, 44, 3)
            elif c == 168:
                return Diff(0, 0, 8, 3)
            elif c == 169:
                return Diff(0, 0, 8, 3)
            elif c == 170:
                return Diff(0, 2, 16, 3)
            elif c == 171:
                return Diff(0, 2, 16, 3)
            elif c == 172:
                return Diff(0, 0, 9, 3)
            elif c == 184:
                return Diff(0, 2, 0, 3)
            elif c == 185:
                return Diff(0, 2, 0, 3)
            elif c == 186:
                return Diff(0, 2, 6, 3)
            elif c == 187:
                return Diff(0, 2, 6, 3)
            elif c == 188:
                return Diff(0, 0, 15, 3)
    elif a == 226:
        if b == 132:
            if c == 166:
                return Diff(45, 13, 166, 2)
            elif c == 170:
                return Diff(137, 132, 170, 1)
            elif c == 171:
                return Diff(33, 33, 171, 2)
            elif c == 178:
                return Diff(0, 1, 60, 3)
        elif b == 133 and c >= 160 and c <= 175:
            return Diff(0, 0, 16, 3)
        elif b == 134 and c == 131:
            return Diff(0, 0, 7, 3)
        elif b == 146:
            if c == 182:
                return Diff(0, 1, 38, 3)
            elif c == 183:
                return Diff(0, 1, 38, 3)
            elif c == 184:
                return Diff(0, 1, 42, 3)
            elif c == 185:
                return Diff(0, 1, 42, 3)
            elif c == 186:
                return Diff(0, 1, 46, 3)
            elif c == 187:
                return Diff(0, 1, 46, 3)
            elif c == 188:
                return Diff(0, 1, 42, 3)
            elif c == 189:
                return Diff(0, 1, 42, 3)
            elif c == 190:
                return Diff(0, 1, 38, 3)
            elif c == 191:
                return Diff(0, 1, 38, 3)
        elif b == 147:
            if c == 128:
                return Diff(0, 0, 26, 3)
            elif c == 129:
                return Diff(0, 0, 26, 3)
            elif c == 130:
                return Diff(0, 0, 30, 3)
            elif c == 131:
                return Diff(0, 0, 30, 3)
            elif c == 132:
                return Diff(0, 0, 26, 3)
            elif c == 133:
                return Diff(0, 0, 26, 3)
            elif c == 134:
                return Diff(0, 0, 38, 3)
            elif c == 135:
                return Diff(0, 0, 38, 3)
            elif c == 136:
                return Diff(0, 0, 42, 3)
            elif c == 137:
                return Diff(0, 0, 42, 3)
            elif c == 138:
                return Diff(0, 0, 46, 3)
            elif c == 139:
                return Diff(0, 0, 46, 3)
            elif c == 140:
                return Diff(0, 0, 42, 3)
            elif c == 141:
                return Diff(0, 0, 42, 3)
            elif c == 142:
                return Diff(0, 0, 38, 3)
            elif c == 143:
                return Diff(0, 0, 38, 3)
        elif b == 176:
            if c >= 128 and c <= 143:
                return Diff(0, 0, 48, 3)
            elif c >= 144 and c <= 159:
                return Diff(0, 1, 16, 3)
            elif c >= 160 and c <= 175:
                return Diff(0, 1, 48, 3)
        elif b == 177:
            if c == 160:
                return Diff(0, 0, 1, 3)
            elif c == 162:
                return Diff(43, 26, 162, 2)
            elif c == 163:
                return Diff(3, 4, 30, 3)
            elif c == 164:
                return Diff(43, 12, 164, 2)
            elif c == 167:
                return Diff(0, 0, 15, 3)
            elif c == 169:
                return Diff(0, 0, 3, 3)
            elif c == 171:
                return Diff(0, 0, 7, 3)
            elif c == 173:
                return Diff(43, 32, 173, 2)
            elif c == 174:
                return Diff(43, 0, 174, 2)
            elif c == 175:
                return Diff(43, 33, 175, 2)
            elif c == 176:
                return Diff(43, 35, 176, 2)
            elif c == 178:
                return Diff(0, 0, 1, 3)
            elif c == 181:
                return Diff(0, 0, 3, 3)
            elif c == 190:
                return Diff(42, 14, 190, 2)
            elif c == 191:
                return Diff(43, 49, 191, 2)
        elif b == 178 and c >= 128 and c <= 190 and c & 1 == 0:
            return Diff(0, 0, 1, 3)
        elif b == 179:
            if c >= 128 and c <= 162 and c & 1 == 0:
                return Diff(0, 0, 1, 3)
            elif c == 171:
                return Diff(0, 0, 7, 3)
            elif c == 173:
                return Diff(0, 0, 3, 3)
            elif c == 178:
                return Diff(0, 0, 1, 3)
    elif a == 234:
        if b == 153 and c >= 128 and c <= 172 and c & 1 == 0:
            return Diff(0, 0, 1, 3)
        elif b == 154 and c >= 128 and c <= 154 and c & 1 == 0:
            return Diff(0, 0, 1, 3)
        elif b == 156 and ((c >= 162 and c <= 174 and c & 1 == 0) or (c >= 178 and c <= 190 and c & 1 == 0)):
            return Diff(0, 0, 1, 3)
        elif b == 157:
            if c >= 128 and c <= 174 and c & 1 == 0:
                return Diff(0, 0, 1, 3)
            elif c == 185:
                return Diff(0, 0, 3, 3)
            elif c == 187:
                return Diff(0, 0, 7, 3)
            elif c == 189:
                return Diff(11, 40, 4, 3)
            elif c == 190:
                return Diff(0, 0, 1, 3)
        elif b == 158:
            if c >= 128 and c <= 134 and c & 1 == 0:
                return Diff(0, 0, 1, 3)
            elif c == 139:
                return Diff(0, 0, 7, 3)
            elif c == 141:
                return Diff(35, 59, 141, 2)
            elif c == 144:
                return Diff(0, 0, 1, 3)
            elif c == 146:
                return Diff(0, 0, 1, 3)
            elif c >= 150 and c <= 168 and c & 1 == 0:
                return Diff(0, 0, 1, 3)
            elif c == 170:
                return Diff(35, 56, 170, 2)
            elif c == 171:
                return Diff(35, 2, 171, 2)
            elif c == 172:
                return Diff(35, 63, 172, 2)
            elif c == 173:
                return Diff(35, 50, 173, 2)
            elif c == 174:
                return Diff(35, 52, 174, 2)
            elif c == 176:
                return Diff(32, 0, 176, 2)
            elif c == 177:
                return Diff(32, 25, 177, 2)
            elif c == 178:
                return Diff(32, 3, 178, 2)
            elif c == 179:
                return Diff(0, 51, 32, 3)
            elif c >= 180 and c <= 190 and c & 1 == 0:
                return Diff(0, 0, 1, 3)
        elif b == 159:
            if c == 128:
                return Diff(0, 0, 1, 3)
            elif c == 130:
                return Diff(0, 0, 1, 3)
            elif c == 132:
                return Diff(0, 1, 16, 3)
            elif c == 133:
                return Diff(32, 29, 133, 2)
            elif c == 134:
                return Diff(11, 41, 8, 3)
            elif c == 135:
                return Diff(0, 0, 15, 3)
            elif c == 137:
                return Diff(0, 0, 3, 3)
            elif c == 144:
                return Diff(0, 0, 1, 3)
            elif c == 150:
                return Diff(0, 0, 1, 3)
            elif c == 152:
                return Diff(0, 0, 1, 3)
            elif c == 181:
                return Diff(0, 0, 3, 3)
    elif a == 239:
        if b == 188 and c >= 161 and c <= 186:
            return Diff(0, 1, 32, 3)
    return Diff(0, 0, 0, 3)


@always_inline
def _to_lower(a: UInt8, b: UInt8, c: UInt8, d: UInt8) -> Diff:
    """Given four bytes of a UTF-8 char, returns XOR masks for lowercasing.
    Returns Diff(xor_byte0, xor_byte1, xor_byte2, xor_byte3).
    """
    if a == 240:
        if b == 144:
            if c == 144:
                if d >= 128 and d <= 135:
                    return Diff(0, 0, 0, 40)
                elif d >= 136 and d <= 143:
                    return Diff(0, 0, 0, 56)
                elif d >= 144 and d <= 151:
                    return Diff(0, 0, 0, 40)
                elif d >= 152 and d <= 159:
                    return Diff(0, 0, 1, 24)
                elif d >= 160 and d <= 167:
                    return Diff(0, 0, 1, 40)
            elif c == 146:
                if d >= 176 and d <= 183:
                    return Diff(0, 0, 1, 40)
                elif d >= 184 and d <= 191:
                    return Diff(0, 0, 1, 24)
            elif c == 147:
                if d >= 128 and d <= 135:
                    return Diff(0, 0, 0, 40)
                elif d >= 136 and d <= 143:
                    return Diff(0, 0, 0, 56)
                elif d >= 144 and d <= 147:
                    return Diff(0, 0, 0, 40)
            elif c == 149:
                if d == 176:
                    return Diff(0, 0, 3, 39)
                elif d >= 177 and d <= 183 and d & 1 == 1:
                    return Diff(0, 0, 3, 41)
                elif d == 178:
                    return Diff(0, 0, 3, 43)
                elif d == 180:
                    return Diff(0, 0, 3, 47)
                elif d == 182:
                    return Diff(0, 0, 3, 43)
                elif d == 184:
                    return Diff(0, 0, 3, 39)
                elif d == 185:
                    return Diff(0, 0, 3, 25)
                elif d == 186:
                    return Diff(0, 0, 3, 27)
                elif d == 188:
                    return Diff(0, 0, 3, 31)
                elif d == 189:
                    return Diff(0, 0, 3, 25)
                elif d == 190:
                    return Diff(0, 0, 3, 27)
                elif d == 191:
                    return Diff(0, 0, 3, 25)
            elif c == 150:
                if d == 128:
                    return Diff(0, 0, 0, 39)
                elif d >= 129 and d <= 135 and d & 1 == 1:
                    return Diff(0, 0, 0, 41)
                elif d == 130:
                    return Diff(0, 0, 0, 43)
                elif d == 132:
                    return Diff(0, 0, 0, 47)
                elif d == 134:
                    return Diff(0, 0, 0, 43)
                elif d == 136:
                    return Diff(0, 0, 0, 39)
                elif d == 137:
                    return Diff(0, 0, 0, 57)
                elif d == 138:
                    return Diff(0, 0, 0, 59)
                elif d == 140:
                    return Diff(0, 0, 0, 63)
                elif d == 141:
                    return Diff(0, 0, 0, 57)
                elif d == 142:
                    return Diff(0, 0, 0, 59)
                elif d == 143:
                    return Diff(0, 0, 0, 57)
                elif d == 144:
                    return Diff(0, 0, 0, 39)
                elif d == 145:
                    return Diff(0, 0, 0, 41)
                elif d == 146:
                    return Diff(0, 0, 0, 43)
                elif d == 148:
                    return Diff(0, 0, 0, 47)
                elif d == 149:
                    return Diff(0, 0, 0, 41)
            elif c == 178 and d >= 128 and d <= 178:
                return Diff(0, 0, 1, 0)
        elif b == 145 and c == 162 and d >= 160 and d <= 191:
            return Diff(0, 0, 1, 32)
        elif b == 150 and c == 185 and d >= 128 and d <= 159:
            return Diff(0, 0, 0, 32)
        elif b == 158 and c == 164:
            if d == 128:
                return Diff(0, 0, 0, 34)
            elif d == 129:
                return Diff(0, 0, 0, 34)
            elif d == 130:
                return Diff(0, 0, 0, 38)
            elif d == 131:
                return Diff(0, 0, 0, 38)
            elif d == 132:
                return Diff(0, 0, 0, 34)
            elif d == 133:
                return Diff(0, 0, 0, 34)
            elif d == 134:
                return Diff(0, 0, 0, 46)
            elif d == 135:
                return Diff(0, 0, 0, 46)
            elif d == 136:
                return Diff(0, 0, 0, 34)
            elif d == 137:
                return Diff(0, 0, 0, 34)
            elif d == 138:
                return Diff(0, 0, 0, 38)
            elif d == 139:
                return Diff(0, 0, 0, 38)
            elif d == 140:
                return Diff(0, 0, 0, 34)
            elif d == 141:
                return Diff(0, 0, 0, 34)
            elif d == 142:
                return Diff(0, 0, 0, 62)
            elif d == 143:
                return Diff(0, 0, 0, 62)
            elif d == 144:
                return Diff(0, 0, 0, 34)
            elif d == 145:
                return Diff(0, 0, 0, 34)
            elif d == 146:
                return Diff(0, 0, 0, 38)
            elif d == 147:
                return Diff(0, 0, 0, 38)
            elif d == 148:
                return Diff(0, 0, 0, 34)
            elif d == 149:
                return Diff(0, 0, 0, 34)
            elif d == 150:
                return Diff(0, 0, 0, 46)
            elif d == 151:
                return Diff(0, 0, 0, 46)
            elif d == 152:
                return Diff(0, 0, 0, 34)
            elif d == 153:
                return Diff(0, 0, 0, 34)
            elif d == 154:
                return Diff(0, 0, 0, 38)
            elif d == 155:
                return Diff(0, 0, 0, 38)
            elif d == 156:
                return Diff(0, 0, 0, 34)
            elif d == 157:
                return Diff(0, 0, 0, 34)
            elif d == 158:
                return Diff(0, 0, 1, 30)
            elif d == 159:
                return Diff(0, 0, 1, 30)
            elif d == 160:
                return Diff(0, 0, 1, 34)
            elif d == 161:
                return Diff(0, 0, 1, 34)
    return Diff(0, 0, 0, 0)


def lower_utf8(s: String) -> String:
    """Convert a UTF-8 encoded string to lowercase using a decision tree.

    Args:
        s: Input string.

    Returns:
        A new string with all characters converted to lowercase.
    """
    comptime SIMD_WIDTH = 8
    var byte_len = s.byte_length()
    var result = String(capacity=byte_len // 2 * 3 + 1)
    var offset = 0
    var p = s.unsafe_ptr()
    var buf = result.unsafe_ptr_mut()
    var count = 0
    while offset < byte_len:
        if offset + SIMD_WIDTH <= byte_len:
            var vec = (p + offset).load[SIMD_WIDTH]()
            if vec.le(127).reduce_and():
                var is_upper = vec.ge(65) & vec.le(90)
                var delta = is_upper.select(
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
        if char_length == 1:
            buf[0] = buf[0] = b0 ^ (Byte((b0 >= 65) & (b0 <= 90)) << 5)
            buf += 1
            count += 1
        elif char_length == 2:
            var b1 = p[offset + 1]
            var diff = _to_lower(b0, b1)
            var out_len = Int(diff[3])
            buf[0] = b0 ^ diff[0]
            # if out_len >= 2:
            buf[1] = b1 ^ diff[1]
            # if out_len >= 3:
            buf[2] = diff[2]
            buf += out_len
            count += out_len
        elif char_length == 3:
            var b1 = p[offset + 1]
            var b2 = p[offset + 2]
            var diff = _to_lower(b0, b1, b2)
            var out_len = Int(diff[3])
            buf[0] = b0 ^ diff[0]
            # if out_len >= 2:
            buf[1] = b1 ^ diff[1]
            # if out_len >= 3:
            buf[2] = b2 ^ diff[2]
            buf += out_len
            count += out_len
        elif char_length == 4:
            var b1 = p[offset + 1]
            var b2 = p[offset + 2]
            var b3 = p[offset + 3]
            var diff = _to_lower(b0, b1, b2, b3)
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

