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


@value
struct STree[dt: DType, B:Int, N: Int]:
    var data: UnsafePointer[Scalar[dt]]
    var height: Int
    var capacity: Int
    var offsets: List[Int]


fn prepare[dt: DType, data: UnsafePointer[Scalar[dt]], B: Int, N: Int]() -> STree[dt, B, N]:
    alias H = height[B](N)
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
    return STree[dt, B, N](btree, H, S, offsets)

