from std.algorithm import vectorize
from std.sys.intrinsics import compressed_store
from std.math import iota
from std.sys.info import simdwidthof

comptime simd_width_i8 = simdwidthof[DType.int8]()


def vectorize_and_exit[
    simd_width: Int, workgroup_function: fn[i: Int](Int) capturing[_] -> Bool
](size: Int):
    var loops = size // simd_width
    for i in range(loops):
        if workgroup_function[simd_width](i * simd_width):
            return

    var rest = size & (simd_width - 1)

    comptime if simd_width >= 64:
        if rest >= 32:
            if workgroup_function[32](size - rest):
                return
            rest -= 32

    comptime if simd_width >= 32:
        if rest >= 16:
            if workgroup_function[16](size - rest):
                return
            rest -= 16

    comptime if simd_width >= 16:
        if rest >= 8:
            if workgroup_function[8](size - rest):
                return
            rest -= 8

    comptime if simd_width >= 8:
        if rest >= 4:
            if workgroup_function[4](size - rest):
                return
            rest -= 4

    comptime if simd_width >= 4:
        if rest >= 2:
            if workgroup_function[2](size - rest):
                return
            rest -= 2

    if rest == 1:
        _ = workgroup_function[1](size - rest)


def find_indices(s: String, c: String) -> List[UInt64]:
    var size = len(s)
    var result = List[UInt64]()
    var char = UInt8(ord(c))
    var p = s.unsafe_ptr()

    @parameter
    fn find[simd_width: Int](offset: Int):
        @parameter
        if simd_width == 1:
            if p.load(offset) == char:
                return result.append(UInt64(offset))
        else:
            var chunk = p.load[width=simd_width](offset)
            var occurrence = chunk.eq(char)
            var offsets = iota[DType.uint64, simd_width]() + SIMD[DType.uint64, simd_width](offset)
            var occurrence_count = occurrence.reduce_bit_count()
            var current_len = len(result)
            result.reserve(current_len + occurrence_count)
            result.resize(current_len + occurrence_count, 0)
            compressed_store(
                offsets,
                result.unsafe_ptr() + current_len,
                occurrence,
            )

    vectorize[find](size)
    return result^


def occurrence_count(s: String, *c: String) -> Int:
    var size = len(s)
    var result = 0
    var chars = List[UInt8]()
    for i in range(len(c)):
        chars.append(UInt8(ord(c[i])))
    var p = s.unsafe_ptr()

    @parameter
    fn find[simd_width: Int](offset: Int):
        @parameter
        if simd_width == 1:
            for i in range(len(chars)):
                var char = chars[i]
                if p.load(offset) == char:
                    result += 1
                    return
        else:
            var chunk = p.load[width=simd_width](offset)
            var occurrence = SIMD[DType.bool, simd_width](False)
            for i in range(len(chars)):
                occurrence |= chunk == chars[i]
            var occurrence_count = occurrence.reduce_bit_count()
            result += occurrence_count

    vectorize_and_exit[simd_width_i8, find](size)
    return result


def contains_any_of(s: String, *c: String) -> Bool:
    var size = len(s)
    var chars = List[UInt8]()
    for i in range(len(c)):
        chars.append(UInt8(ord(c[i])))
    var p = s.unsafe_ptr()
    var flag = False

    @parameter
    fn find[simd_width: Int](i: Int) -> Bool:
        var chunk = p.load[width=simd_width]()
        p = p + simd_width
        for i in range(len(chars)):
            var occurrence = chunk == chars[i]
            if occurrence.reduce_add():
                flag = True
                return flag
        return False

    vectorize_and_exit[simd_width_i8, find](size)

    return flag


@always_inline
def string_from_pointer(p: UnsafePointer[UInt8, MutExternalOrigin], length: Int) -> String:
    # Since Mojo 0.5.0 the pointer needs to provide a 0 terminated byte string
    p.store(length - 1, 0)
    return String(p, length)


def print_v(v: List[UInt64]):
    print("(" + String(len(v)) + ")[")
    for i in range(len(v)):
        var end = ", " if i < len(v) - 1 else "]\n"
        print(v[i], end=end)
