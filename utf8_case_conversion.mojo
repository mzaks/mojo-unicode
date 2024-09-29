from utf8_case_lookups import *
from bit import count_leading_zeros, byte_swap
from memory import bitcast, UnsafePointer
from sys import is_big_endian

@always_inline
fn _to_index_16[lookup: List[UInt16]](x: UInt16) -> Int:
    """Find index of rune in lookup with binary search.
    Returns -1 if not found."""
    var cursor = 0
    var b = lookup.data
    var length = len(lookup)
    while length > 1:
        var half = length >> 1
        length -= half
        cursor += int(b.load(cursor + half - 1) < x) * half

    return cursor if b.load(cursor) == x else -1

@always_inline
fn _to_index_32[lookup: List[UInt32]](x: UInt32) -> Int:
    """Find index of rune in lookup with binary search.
    Returns -1 if not found."""
    var cursor = 0
    var b = lookup.data
    var length = len(lookup)
    while length > 1:
        var half = length >> 1
        length -= half
        cursor += int(b.load(cursor + half - 1) < x) * half

    return cursor if b.load(cursor) == x else -1

@always_inline
fn _to_lower(a: UInt8) -> UInt8:
    """Branch free lower case for ASCII. Returns value which needs to be added to char.
    """
    var lower = a >= 65
    var upper = a <= 90
    var add = lower and upper
    return (a + 32) * int(add) + (a * int(not add))

fn to_lowercase(s: String) -> String:
    var input = s.unsafe_ptr()
    var input_length = s.byte_length()
    var capacity = (input_length >> 1) * 3 + 1
    var output = UnsafePointer[UInt8].alloc(capacity)
    var input_offset = 0
    var output_offset = 0
    while input_offset < input_length:
        var b = input[input_offset]
        var flipped = ~b
        var bytes = (flipped >> 7) + count_leading_zeros(flipped)
        if bytes == 1:
            output[output_offset] = _to_lower(b)
            output_offset += 1
        elif bytes == 2:
            var u16 = input.bitcast[DType.uint16]()[]
            @parameter
            if is_big_endian():
                u16 = byte_swap(u16)
            var index = _to_index_16[has_lower_case_2](u16)
            if index == -1:
                output.offset(output_offset).store(input.offset(input_offset).load[width=2]())
                output_offset += 2
            else:
                var v = lower_case_mapping_2[index]
                output.offset(output_offset).store[width=4](v)
                output_offset += int(v[3])
        elif bytes == 3:
            var v = input.load[width=4]()
            v[3] = 0
            var u32 = bitcast[DType.uint32, 1](v)
            @parameter
            if is_big_endian():
                u32 = byte_swap(u32)
            var index = _to_index_32[has_lower_case_3](u32)

            if index == -1:
                output.offset(output_offset).store(input.offset(input_offset).load[width=4]())
                output_offset += 3
            else:
                var v = lower_case_mapping_3[index]
                output.offset(output_offset).store[width=4](v)
                output_offset += int(v[3])
        elif bytes == 4:
            var u32 = input.bitcast[DType.uint32]()[]
            @parameter
            if is_big_endian():
                u32 = byte_swap(u32)
            var index = _to_index_32[has_lower_case_4](u32)
            if index == -1:
                output.offset(output_offset).store(input.offset(input_offset).load[width=4]())
                output_offset += 4
            else:
                var v = lower_case_mapping_4[index]
                output.offset(output_offset).store[width=4](v)
                output_offset += 4

        input_offset += int(bytes)

    output[output_offset] = 0
    var list = List[UInt8](
        unsafe_pointer=output, size=(output_offset + 1), capacity=capacity
    )
    return String(list)

from stree import index as stree_index
from utf8_case_lookups_stree import *

fn to_lowercase2(s: String) -> String:
    var input = s.unsafe_ptr()
    var input_length = s.byte_length()
    var capacity = (input_length >> 1) * 3 + 1
    var output = UnsafePointer[UInt8].alloc(capacity)
    var input_offset = 0
    var output_offset = 0
    while input_offset < input_length:
        var b = input[input_offset]
        var flipped = ~b
        var bytes = (flipped >> 7) + count_leading_zeros(flipped)
        if bytes == 1:
            output[output_offset] = _to_lower(b)
            output_offset += 1
        elif bytes == 2:
            var u16 = input.bitcast[DType.uint16]()[]
            @parameter
            if is_big_endian():
                u16 = byte_swap(u16)
            var index = stree_index(has_lower_case_2_stree.data, has_lower_case_2_stree_offsets, u16)
            if index == -1:
                output.offset(output_offset).store(input.offset(input_offset).load[width=2]())
                output_offset += 2
            else:
                var v = lower_case_mapping_2[index]
                output.offset(output_offset).store[width=4](v)
                output_offset += int(v[3])
        elif bytes == 3:
            var v = input.load[width=4]()
            v[3] = 0
            var u32 = bitcast[DType.uint32, 1](v)
            @parameter
            if is_big_endian():
                u32 = byte_swap(u32)
            var index = stree_index(has_lower_case_3_stree.data, has_lower_case_3_stree_offsets, u32)

            if index == -1:
                output.offset(output_offset).store(input.offset(input_offset).load[width=4]())
                output_offset += 3
            else:
                var v = lower_case_mapping_3[index]
                output.offset(output_offset).store[width=4](v)
                output_offset += int(v[3])
        elif bytes == 4:
            var u32 = input.bitcast[DType.uint32]()[]
            @parameter
            if is_big_endian():
                u32 = byte_swap(u32)
            var index = stree_index(has_lower_case_4_stree.data, has_lower_case_4_stree_offsets, u32)
            if index == -1:
                output.offset(output_offset).store(input.offset(input_offset).load[width=4]())
                output_offset += 4
            else:
                var v = lower_case_mapping_4[index]
                output.offset(output_offset).store[width=4](v)
                output_offset += 4

        input_offset += int(bytes)

    output[output_offset] = 0
    var list = List[UInt8](
        unsafe_pointer=output, size=(output_offset + 1), capacity=capacity
    )
    return String(list)