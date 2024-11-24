from utf8_case_lookups import *
from stree import prepare, index, height, index2 #, index4
from time import now
from utils import unroll
from bit import bit_width
from benchmark import run, Report
from testing import assert_equal

@always_inline
fn bsearch_index[dt: DType, lookup: List[Scalar[dt]]](x: Scalar[dt]) -> Int:
    var cursor = 0
    var b = lookup.data
    var length = len(lookup)
    while length > 1:
        var half = length >> 1
        length -= half
        cursor += int(b.load(cursor + half - 1) < x) * half

    return cursor if b.load(cursor) == x else -1

@always_inline
fn bsearch_index_unrolled[dt: DType, lookup: List[Scalar[dt]]](x: Scalar[dt]) -> Int:
    fn log2(_i: Int) -> Int:
        var i = _i >> 1
        var result = 1
        while i:
            i >>= 1
            result += 1
        return result
    alias depth = log2(len(lookup))
    
    var cursor = 0
    var b = lookup.data
    var length = len(lookup)
    @parameter
    fn search[i: Int]():
        var half = length >> 1
        length -= half
        cursor += int(b.load(cursor + half - 1) < x) * half
    
    unroll[search, depth]()

    return cursor if b.load(cursor) == x else -1

@always_inline
fn bsearch_index_default[dt: DType, lookup: List[Scalar[dt]]](x: Scalar[dt]) -> Int:
    var low = 0
    var high = len(lookup) - 1
    var b = lookup.data
    while low <= high:
        var mid = (high + low) >> 1
        var mid_value = b.load(mid)
        if mid_value < x:
            low = mid + 1
        elif mid_value > x:
            high = mid - 1
        else:
            return mid
    return -1


fn validate(l: List[Int]) raises:
    for i in range(len(l)):
        assert_equal(i, l[i])


fn main() raises:

    var indices = List[Int]()

    @parameter
    fn find[dt: DType, list: List[Scalar[dt]], f: fn[dt:DType, list:List[Scalar[dt]]](Scalar[dt]) -> Int]():
        indices.clear()
        for i in list:
            indices.append(f[dt, list](i[]))

    var report: Report

    print("Binary Search")
    report = run[find[DType.uint16, has_lower_case_2, bsearch_index_default]]()
    print(str("has_lower_case_2").ljust(20), report.mean("ms"))
    validate(indices)

    report = run[find[DType.uint32, has_lower_case_3, bsearch_index_default]]()
    print(str("has_lower_case_3").ljust(20), report.mean("ms"))
    validate(indices)

    report = run[find[DType.uint32, has_lower_case_4, bsearch_index_default]]()
    print(str("has_lower_case_4").ljust(20), report.mean("ms"))
    validate(indices)

    print("Branch free Binary Search")
    report = run[find[DType.uint16, has_lower_case_2, bsearch_index]]()
    print(str("has_lower_case_2").ljust(20), report.mean("ms"))
    validate(indices)

    report = run[find[DType.uint32, has_lower_case_3, bsearch_index]]()
    print(str("has_lower_case_3").ljust(20), report.mean("ms"))
    validate(indices)

    report = run[find[DType.uint32, has_lower_case_4, bsearch_index]]()
    print(str("has_lower_case_4").ljust(20), report.mean("ms"))
    validate(indices)

    print("Branch free Unrolled Binary Search")
    report = run[find[DType.uint16, has_lower_case_2, bsearch_index_unrolled]]()
    print(str("has_lower_case_2").ljust(20), report.mean("ms"))
    validate(indices)

    report = run[find[DType.uint32, has_lower_case_3, bsearch_index_unrolled]]()
    print(str("has_lower_case_3").ljust(20), report.mean("ms"))
    validate(indices)

    report = run[find[DType.uint32, has_lower_case_4, bsearch_index_unrolled]]()
    print(str("has_lower_case_4").ljust(20), report.mean("ms"))
    validate(indices)


    alias b = 16
    alias l2 = len(has_lower_case_2)
    alias l3 = len(has_lower_case_3)
    alias l4 = len(has_lower_case_4)

    alias h2 = height[b](l2)
    alias h3 = height[b](l3)
    alias h4 = height[b](l4)

    alias btree2 = prepare[DType.uint16, has_lower_case_2.data, b, l2, h2]()
    alias btree3 = prepare[DType.uint32, has_lower_case_3.data, b, l3, h3]()
    alias btree4 = prepare[DType.uint32, has_lower_case_4.data, b, l4, h4]()

    @parameter
    fn find_stree2():
        indices.clear()
        for i in has_lower_case_2:
            indices.append(index[DType.uint16](btree2.data, btree2.offsets, i[]))

    @parameter
    fn find_stree3():
        indices.clear()
        for i in has_lower_case_3:
            indices.append(index[DType.uint32](btree3.data, btree3.offsets, i[]))

    @parameter
    fn find_stree4():
        indices.clear()
        for i in has_lower_case_4:
            indices.append(index[DType.uint32](btree4.data, btree4.offsets, i[]))

    @parameter
    fn find2_stree2():
        indices.clear()
        for i in has_lower_case_2:
            indices.append(index2[btree2.dt, btree2.B, btree2.H](btree2.data, btree2.offsets, i[]))

    @parameter
    fn find2_stree3():
        indices.clear()
        for i in has_lower_case_3:
            indices.append(index2[btree3.dt, btree3.B, btree3.H](btree3.data, btree3.offsets, i[]))

    @parameter
    fn find2_stree4():
        indices.clear()
        for i in has_lower_case_4:
            indices.append(index2[btree4.dt, btree4.B, btree4.H](btree4.data, btree4.offsets, i[]))

    # @parameter
    # fn find4_stree2():
    #     indices.clear()
    #     for i in has_lower_case_2:
    #         indices.append(index4[btree2.dt, btree2.B, btree2.N, btree2.H, btree2](i[]))

    # @parameter
    # fn find4_stree3():
    #     indices.clear()
    #     for i in has_lower_case_3:
    #         indices.append(index4[btree3.dt, btree3.B, btree3.N, btree3.H, btree3](i[]))

    # @parameter
    # fn find4_stree4():
    #     indices.clear()
    #     for i in has_lower_case_4:
    #         indices.append(index4[btree4.dt, btree4.B, btree4.N, btree4.H, btree4](i[]))

    print("STree")
    report = run[find_stree2]()
    print(str("has_lower_case_2").ljust(20), report.mean("ms"))
    validate(indices)

    report = run[find_stree3]()
    print(str("has_lower_case_3").ljust(20), report.mean("ms"))
    validate(indices)

    report = run[find_stree4]()
    print(str("has_lower_case_4").ljust(20), report.mean("ms"))
    validate(indices)

    print("STree 2")

    report = run[find2_stree2]()
    print(str("has_lower_case_2").ljust(20), report.mean("ms"))
    validate(indices)

    report = run[find2_stree3]()
    print(str("has_lower_case_3").ljust(20), report.mean("ms"))
    validate(indices)

    report = run[find2_stree4]()
    print(str("has_lower_case_4").ljust(20), report.mean("ms"))
    validate(indices)

    # print("STree 4")

    # report = run[find4_stree2]()
    # print(str("has_lower_case_2").ljust(20), report.mean("ms"))
    # validate(indices)

    # report = run[find4_stree3]()
    # print(str("has_lower_case_3").ljust(20), report.mean("ms"))
    # validate(indices)

    # report = run[find4_stree4]()
    # print(str("has_lower_case_4").ljust(20), report.mean("ms"))
    # validate(indices)

    # _ = btree2^
    # _ = btree3^
    # _ = btree4^
    # _ = indices^
