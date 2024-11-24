# Based on https://en.algorithmica.org/hpc/data-structures/s-tree/


from bit import pop_count, count_trailing_zeros
from memory import memcpy, bitcast, UnsafePointer


fn blocks[B: Int](n: Int) -> Int:
    return (n + B - 1) // B


fn prev_keys[B: Int](n: Int) -> Int:
    return (blocks[B](n) + B) // (B + 1) * B


fn height[B: Int](n: Int) -> Int:
    return 1 if n <= B else height[B](prev_keys[B](n)) + 1


fn offset[B: Int, N: Int](h: Int) -> Int:
    var k = 0
    var n = N
    for _ in range(h, 0, -1):
        k += blocks[B](n) * B
        n = prev_keys[B](n)
    return k

@always_inline
fn index[dt: DType](p: UnsafePointer[Scalar[dt]], offsets: List[Int], _x: Scalar[dt]) -> Int:
    var height = len(offsets) + 1
    @always_inline
    fn rank(x: SIMD[dt, 16], p: UnsafePointer[Scalar[dt]]) -> Int:
        var mask = p.load[width=16]() > x
        var mask_v = bitcast[DType.uint16](mask)
        return int(count_trailing_zeros(mask_v))
    var k = 0
    var x = SIMD[dt, 16](_x - 1)
    for h in range(height - 1, 0, -1):
        var i = rank(x, p + int(offsets[h-1]) + k)
        k = k * (16 + 1) + (i << 4)
    var i = rank(x, p + k)
    var lower_bound_index = k + i
    return lower_bound_index if p[lower_bound_index] == _x else -1

@always_inline
fn index3[dt: DType](st: STree[dt], _x: Scalar[dt]) -> Int:
    @always_inline
    fn rank(x: SIMD[dt, st.B], p: UnsafePointer[Scalar[dt]]) -> Int:
        @parameter
        if st.B == 8:
            var mask = p.load[width=st.B]() > x
            var mask_v = bitcast[DType.uint8](mask)
            return int(count_trailing_zeros(mask_v))
        elif st.B == 16:
            var mask = p.load[width=st.B]() > x
            var mask_v = bitcast[DType.uint16](mask)
            return int(count_trailing_zeros(mask_v))
        elif st.B == 32:
            var mask = p.load[width=st.B]() > x
            var mask_v = bitcast[DType.uint32](mask)
            return int(count_trailing_zeros(mask_v))
        elif st.B == 64:
            var mask = p.load[width=st.B]() > x
            var mask_v = bitcast[DType.uint64](mask)
            return int(count_trailing_zeros(mask_v))
        else:
            var mask = p.load[width=st.B]() <= x
            return int(mask.cast[DType.uint8]().reduce_add())
    var k = 0
    var x = SIMD[dt, st.B](_x - 1)
    @parameter
    for h in range(st.H - 1, 0, -1):
        var i = rank(x, st.data + int(st.offsets[h-1]) + k)
        k = k * (st.B + 1) + (i * st.B)
    var i = rank(x, st.data + k)
    var lower_bound_index = k + i
    return lower_bound_index if st.data[lower_bound_index] == _x else -1

# @always_inline
# fn index4[dt: DType, B: Int, N: Int, H: Int, st: STree[dt, B, N, H]](_x: Scalar[dt]) -> Int:
#     @always_inline
#     fn rank(x: SIMD[dt, st.B], p: UnsafePointer[Scalar[dt]]) -> Int:
#         @parameter
#         if st.B == 8:
#             var mask = p.load[width=st.B]() > x
#             var mask_v = bitcast[DType.uint8](mask)
#             return int(count_trailing_zeros(mask_v))
#         elif st.B == 16:
#             var mask = p.load[width=st.B]() > x
#             var mask_v = bitcast[DType.uint16](mask)
#             return int(count_trailing_zeros(mask_v))
#         elif st.B == 32:
#             var mask = p.load[width=st.B]() > x
#             var mask_v = bitcast[DType.uint32](mask)
#             return int(count_trailing_zeros(mask_v))
#         elif st.B == 64:
#             var mask = p.load[width=st.B]() > x
#             var mask_v = bitcast[DType.uint64](mask)
#             return int(count_trailing_zeros(mask_v))
#         else:
#             var mask = p.load[width=st.B]() <= x
#             return int(mask.cast[DType.uint8]().reduce_add())
#     var k = 0
#     var x = SIMD[dt, st.B](_x - 1)
#     @parameter
#     for h in range(st.H - 1, 0, -1):
#         var i = rank(x, st.data + int(st.offsets[h-1]) + k)
#         k = k * (st.B + 1) + (i * st.B)
#     var i = rank(x, st.data + k)
#     var lower_bound_index = k + i
#     return lower_bound_index if st.data[lower_bound_index] == _x else -1


@always_inline
fn index2[dt: DType, B: Int, H: Int](p: UnsafePointer[Scalar[dt]], offsets: List[Int], _x: Scalar[dt]) -> Int:
    @always_inline
    fn rank(x: SIMD[dt, B], p: UnsafePointer[Scalar[dt]]) -> Int:
        @parameter
        if B == 8:
            var mask = p.load[width=B]() > x
            var mask_v = bitcast[DType.uint8](mask)
            return int(count_trailing_zeros(mask_v))
        elif B == 16:
            var mask = p.load[width=B]() > x
            var mask_v = bitcast[DType.uint16](mask)
            return int(count_trailing_zeros(mask_v))
        elif B == 32:
            var mask = p.load[width=B]() > x
            var mask_v = bitcast[DType.uint32](mask)
            return int(count_trailing_zeros(mask_v))
        elif B == 64:
            var mask = p.load[width=B]() > x
            var mask_v = bitcast[DType.uint64](mask)
            return int(count_trailing_zeros(mask_v))
        else:
            var mask = p.load[width=B]() <= x
            return int(mask.cast[DType.uint8]().reduce_add())

    var k = 0
    var x = SIMD[dt, B](_x - 1)
    @parameter
    for h in range(H - 1, 0, -1):
        var i = rank(x, p + int(offsets[h-1]) + k)
        k = k * (B + 1) + (i * B)
    var i = rank(x, p + k)
    var lower_bound_index = k + i
    return lower_bound_index if p[lower_bound_index] == _x else -1

@value
struct STree[dt: DType, B:Int, N: Int, H: Int]:
    var data: UnsafePointer[Scalar[dt]]
    var capacity: Int
    var offsets: List[Int]


fn prepare[dt: DType, data: UnsafePointer[Scalar[dt]], B: Int, N: Int, H: Int]() -> STree[dt, B, N, H]:
    # alias H = height[B](N)
    alias S = offset[B, N](H)
    var btree = UnsafePointer[Scalar[dt]].alloc(S)
    memcpy(btree, data, N)
    for i in range(N, S):
        btree[i] = Scalar[dt].MAX
    
    var offsets = List[Int]()
    for h in range(1, H):
        offsets.append(offset[B, N](h))
        var layer_size = offset[B, N](h + 1) - offset[B, N](h)
        for i in range(layer_size):
            var k = i // B
            var j = i - k * B
            k = k * (B + 1) + j + 1
            for _ in range(h - 1):
                k *= (B + 1)
            btree[offset[B, N](h) + i] = btree[int(k * B)] if k * B < N else Scalar[dt].MAX
    return STree[dt, B, N, H](btree, S, offsets)


def main():
    alias list = List[UInt32](1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25)
    st = prepare[DType.uint32, list.data, 8, len(list), height[8](len(list))]()
    print(st.H)
    print(st.offsets.__str__())
    print(st.capacity)
    for i in range(st.capacity):
        print(st.data[i], end="," if i < st.capacity - 1 else "\n")
    print(index2[st.dt, st.B, st.H](st.data, st.offsets, 11))
    for i in list:
        print(i[], "=", index2[st.dt, st.B, st.H](st.data, st.offsets, i[]), end=", ")
    print()
