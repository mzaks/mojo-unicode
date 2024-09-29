from utf8_case_lookups import *
from stree import prepare, index
from time import now
from utils import unroll
from bit import bit_width

fn bsearch_index[dt: DType, lookup: List[Scalar[dt]]](x: Scalar[dt]) -> Int:
    var cursor = 0
    var b = lookup.data
    var length = len(lookup)
    while length > 1:
        var half = length >> 1
        length -= half
        cursor += int(b.load(cursor + half - 1) < x) * half

    return cursor if b.load(cursor) == x else -1

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

fn measure_stree[dt: DType, list: List[Scalar[dt]]]():
    var btree = prepare[dt, list.data, 16, len(list)]()
    var indices = List[Int](capacity=len(list))
    var start = now()
    var rounds = 200
    for _ in range(rounds):
        indices.clear()
        for i in list:
            indices.append(index[dt](btree.data, btree.offsets, i[]))
    var duration = now() - start
    for i in range(len(indices)):
        if indices[i] != i:
            print("!!!")
    print(duration / rounds / len(indices))

fn measure_bsearch[dt: DType, list: List[Scalar[dt]]]():
    var indices = List[Int](capacity=len(list))
    var start = now()
    var rounds = 200
    for _ in range(rounds):
        indices.clear()
        for i in list:
            indices.append(bsearch_index[dt, list](i[]))
    var duration = now() - start
    for i in range(len(indices)):
        if indices[i] != i:
            print("!!!")
    print(duration / rounds / len(indices))

fn measure_bsearch_urolled[dt: DType, list: List[Scalar[dt]]]():
    var indices = List[Int](capacity=len(list))
    var start = now()
    var rounds = 200
    for _ in range(rounds):
        indices.clear()
        for i in list:
            indices.append(bsearch_index_unrolled[dt, list](i[]))
    var duration = now() - start
    for i in range(len(indices)):
        if indices[i] != i:
            print("!!!")
    print(duration / rounds / len(indices))

fn measure_bsearch_default[dt: DType, list: List[Scalar[dt]]]():
    var indices = List[Int](capacity=len(list))
    var start = now()
    var rounds = 200
    for _ in range(rounds):
        indices.clear()
        for i in list:
            indices.append(bsearch_index_default[dt, list](i[]))
    var duration = now() - start
    for i in range(len(indices)):
        if indices[i] != i:
            print("!!!")
    print(duration / rounds / len(indices))

fn main():
    print("--- STree Search ---")
    measure_stree[DType.uint16, has_lower_case_2]()
    measure_stree[DType.uint32, has_lower_case_3]()
    measure_stree[DType.uint32, has_lower_case_4]()
    print("--- Binary Search Branchless ---")
    measure_bsearch[DType.uint16, has_lower_case_2]()
    measure_bsearch[DType.uint32, has_lower_case_3]()
    measure_bsearch[DType.uint32, has_lower_case_4]()
    print("--- Binary Search Branchless Unrolled ---")
    measure_bsearch_urolled[DType.uint16, has_lower_case_2]()
    measure_bsearch_urolled[DType.uint32, has_lower_case_3]()
    measure_bsearch_urolled[DType.uint32, has_lower_case_4]()
    print("--- Binary Search Default ---")
    measure_bsearch_default[DType.uint16, has_lower_case_2]()
    measure_bsearch_default[DType.uint32, has_lower_case_3]()
    measure_bsearch_default[DType.uint32, has_lower_case_4]()
