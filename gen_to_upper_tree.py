#!/usr/bin/env python3
"""Generate a Mojo decision-tree to_upper implementation from to_upper.csv.

This script reads the CSV file with Unicode lowercase-to-titlecase mappings
and generates optimized Mojo code that performs titlecasing by computing
byte-level adjustments on raw UTF-8 bytes, with no lookup tables.

Multi-character expansions (dst_len > 3 for src_len <= 3) cannot be
represented in the 4-slot Diff and are skipped.

Usage:
    python3 gen_to_upper_tree.py > to_upper.mojo
"""

import csv
from collections import defaultdict
from dataclasses import dataclass


@dataclass
class Mapping:
    src_hex: str
    src_bytes: list[int]
    dst_bytes: list[int]
    diff_bytes: list[int]
    src_len: int
    dst_len: int


def parse_csv(filename: str) -> list[Mapping]:
    mappings = []
    with open(filename) as f:
        reader = csv.reader(f)
        next(reader)  # skip header
        for row in reader:
            src_len = int(row[3])
            dst_len = int(row[8])
            src_bytes = list(map(int, row[4].split()))
            dst_bytes = list(map(int, row[9].split()))
            diff_bytes = list(map(int, row[11].split()))
            mappings.append(Mapping(
                src_hex=row[0],
                src_bytes=src_bytes,
                dst_bytes=dst_bytes,
                diff_bytes=diff_bytes,
                src_len=src_len,
                dst_len=dst_len,
            ))
    return mappings


def group_by_src_len(mappings: list[Mapping]) -> dict[int, list[Mapping]]:
    groups = defaultdict(list)
    for m in mappings:
        groups[m.src_len].append(m)
    return dict(groups)


def compute_return_tuple(m: Mapping, src_len: int) -> tuple:
    """Compute the 8-element return tuple for a mapping.

    Layout (SIMD[DType.int16, 8]):
      2-byte: (delta0, delta1, extra2, extra3, extra4, extra5, out_len, 0)
      3-byte: (delta0, delta1, delta2, extra3, extra4, extra5, out_len, 0)
      4-byte: (delta0, delta1, delta2, delta3, 0, 0, 0, 0)

    deltas = dst_byte[i] - src_byte[i] for the first min(src_len, dst_len) bytes.
    extras = absolute output bytes beyond the src_len (0 if unused).
    out_len = number of output bytes.
    """
    if src_len == 1:
        return (32,)  # always +32 for ASCII

    if src_len == 2:
        d0 = m.dst_bytes[0] - m.src_bytes[0]
        d1 = m.dst_bytes[1] - m.src_bytes[1] if m.dst_len >= 2 else 0
        extra = [0, 0, 0, 0]
        for i in range(2, min(m.dst_len, 6)):
            extra[i - 2] = m.dst_bytes[i]
        return (d0, d1, extra[0], extra[1], extra[2], extra[3], m.dst_len, 0)

    if src_len == 3:
        d0 = m.dst_bytes[0] - m.src_bytes[0]
        d1 = m.dst_bytes[1] - m.src_bytes[1] if m.dst_len >= 2 else 0
        d2 = m.dst_bytes[2] - m.src_bytes[2] if m.dst_len >= 3 else 0
        extra = [0, 0, 0]
        for i in range(3, min(m.dst_len, 6)):
            extra[i - 3] = m.dst_bytes[i]
        return (d0, d1, d2, extra[0], extra[1], extra[2], m.dst_len, 0)

    if src_len == 4:
        d0 = m.dst_bytes[0] - m.src_bytes[0]
        d1 = m.dst_bytes[1] - m.src_bytes[1]
        d2 = m.dst_bytes[2] - m.src_bytes[2]
        d3 = m.dst_bytes[3] - m.src_bytes[3]
        return (d0, d1, d2, d3, 0, 0, 0, 0)

    raise ValueError(f"Unsupported src_len: {src_len}")


@dataclass
class RangeGroup:
    """A contiguous range of byte values with the same return tuple."""
    lo: int
    hi: int
    ret: tuple
    even_only: bool = False
    odd_only: bool = False


def find_contiguous_sub_ranges(vals: list[int], step: int = 1) -> list[tuple[int, int]]:
    """Split sorted values into contiguous sub-ranges with given step."""
    if not vals:
        return []
    ranges = []
    start = vals[0]
    prev = vals[0]
    for v in vals[1:]:
        if v == prev + step:
            prev = v
        else:
            ranges.append((start, prev))
            start = v
            prev = v
    ranges.append((start, prev))
    return ranges


def find_patterns(byte_values: list[int], ret_map: dict[int, tuple]) -> list:
    """Find patterns in a set of (byte_value -> return_tuple) mappings.
    Returns a list of RangeGroup for code generation.
    """
    if not byte_values:
        return []

    # Group consecutive values with the same return tuple
    by_ret = defaultdict(list)
    for bv in sorted(byte_values):
        by_ret[ret_map[bv]].append(bv)

    patterns = []
    for ret, vals in sorted(by_ret.items(), key=lambda x: x[1][0]):
        vals = sorted(vals)

        handled = set()

        # First, find contiguous sub-ranges (step=1)
        for lo, hi in find_contiguous_sub_ranges(vals, step=1):
            count = hi - lo + 1
            if count >= 3:
                patterns.append(RangeGroup(lo, hi, ret))
                handled.update(range(lo, hi + 1))

        remaining = sorted(v for v in vals if v not in handled)
        even_vals = sorted(v for v in remaining if v % 2 == 0)
        odd_vals = sorted(v for v in remaining if v % 2 == 1)

        # Find contiguous even sub-ranges (step=2)
        for lo, hi in find_contiguous_sub_ranges(even_vals, step=2):
            count = (hi - lo) // 2 + 1
            if count >= 3:
                patterns.append(RangeGroup(lo, hi, ret, even_only=True))
                handled.update(range(lo, hi + 1, 2))

        # Find contiguous odd sub-ranges (step=2)
        for lo, hi in find_contiguous_sub_ranges(odd_vals, step=2):
            count = (hi - lo) // 2 + 1
            if count >= 3:
                patterns.append(RangeGroup(lo, hi, ret, odd_only=True))
                handled.update(range(lo, hi + 1, 2))

        # Remaining individual values
        for v in vals:
            if v not in handled:
                patterns.append(RangeGroup(v, v, ret))

    # Sort by lo value
    patterns.sort(key=lambda p: p.lo)
    return patterns


def fmt_ret(ret: tuple) -> str:
    """Format a return tuple as Mojo code using Diff (SIMD[DType.int32, 4])."""
    return f"Diff({', '.join(str(x) for x in ret)})"


def gen_condition(p: RangeGroup, var_name: str) -> str:
    """Generate condition expression for a pattern."""
    if p.lo == p.hi:
        base = f"{var_name} == {p.lo}"
    else:
        base = f"{var_name} >= {p.lo} and {var_name} <= {p.hi}"

    if p.even_only:
        if p.lo == p.hi:
            return base
        return f"{base} and {var_name} & 1 == 0"
    elif p.odd_only:
        if p.lo == p.hi:
            return base
        return f"{base} and {var_name} & 1 == 1"
    return base


def generate_2byte(mappings: list[Mapping]) -> str:
    """Generate the 2-byte _to_upper function."""
    lines = []
    lines.append("@always_inline")
    lines.append("def _to_upper(a: UInt8, b: UInt8) -> Diff:")
    lines.append('    """Given two bytes of a UTF-8 char, returns byte adjustments for uppercasing.')
    lines.append("    Returns Diff(delta_byte0, delta_byte1, extra_byte, output_len).")
    lines.append('    """')

    # Group by first byte
    by_first = defaultdict(list)
    for m in mappings:
        by_first[m.src_bytes[0]].append(m)

    first = True
    for fb in sorted(by_first.keys()):
        group = by_first[fb]
        prefix = "if" if first else "elif"
        first = False

        lines.append(f"    {prefix} a == {fb}:")

        # Build a map from second byte to return tuple
        ret_map = {}
        for m in group:
            ret = compute_return_tuple(m, 2)
            ret_map[m.src_bytes[1]] = ret

        patterns = find_patterns(list(ret_map.keys()), ret_map)

        # Group patterns by return value to merge conditions
        by_ret_ordered = []
        seen_rets = {}
        for p in patterns:
            if p.ret not in seen_rets:
                seen_rets[p.ret] = len(by_ret_ordered)
                by_ret_ordered.append((p.ret, [p]))
            else:
                by_ret_ordered[seen_rets[p.ret]][1].append(p)

        emitted_first = True
        for ret, ps in by_ret_ordered:
            p_prefix = "if" if emitted_first else "elif"
            emitted_first = False
            if len(ps) == 1 and ps[0].lo == ps[0].hi:
                lines.append(f"        {p_prefix} b == {ps[0].lo}:")
            elif len(ps) == 1:
                cond = gen_condition(ps[0], "b")
                lines.append(f"        {p_prefix} {cond}:")
            else:
                conds = [gen_condition(p, "b") for p in ps]
                combined = " or ".join(f"({c})" for c in conds)
                lines.append(f"        {p_prefix} {combined}:")
            lines.append(f"            return {fmt_ret(ret)}")

    lines.append("    return Diff(0, 0, 0, 0, 0, 0, 2, 0)")
    return "\n".join(lines)


def generate_3byte(mappings: list[Mapping]) -> str:
    """Generate the 3-byte _to_upper function."""
    lines = []
    lines.append("@always_inline")
    lines.append("def _to_upper(a: UInt8, b: UInt8, c: UInt8) -> Diff:")
    lines.append('    """Given three bytes of a UTF-8 char, returns byte adjustments for uppercasing.')
    lines.append("    Returns Diff(delta_byte0, delta_byte1, delta_byte2, output_len).")
    lines.append('    """')

    # Group by first byte
    by_first = defaultdict(list)
    for m in mappings:
        by_first[m.src_bytes[0]].append(m)

    first_a = True
    for fa in sorted(by_first.keys()):
        group_a = by_first[fa]
        prefix_a = "if" if first_a else "elif"
        first_a = False
        lines.append(f"    {prefix_a} a == {fa}:")

        # Group by second byte
        by_second = defaultdict(list)
        for m in group_a:
            by_second[m.src_bytes[1]].append(m)

        first_b = True
        for fb in sorted(by_second.keys()):
            group_b = by_second[fb]
            prefix_b = "if" if first_b else "elif"
            first_b = False

            # Build ret_map for third byte
            ret_map = {}
            for m in group_b:
                ret = compute_return_tuple(m, 3)
                ret_map[m.src_bytes[2]] = ret

            patterns = find_patterns(list(ret_map.keys()), ret_map)

            # If only one pattern/value
            if len(patterns) == 1 and patterns[0].lo == patterns[0].hi:
                p = patterns[0]
                lines.append(f"        {prefix_b} b == {fb} and c == {p.lo}:")
                lines.append(f"            return {fmt_ret(p.ret)}")
            elif len(patterns) == 1:
                p = patterns[0]
                cond_c = gen_condition(p, "c")
                lines.append(f"        {prefix_b} b == {fb} and {cond_c}:")
                lines.append(f"            return {fmt_ret(p.ret)}")
            else:
                # Check if all patterns have same return tuple
                all_rets = set(p.ret for p in patterns)
                if len(all_rets) == 1:
                    ret = patterns[0].ret
                    conds = [gen_condition(p, "c") for p in patterns]
                    combined = " or ".join(f"({c})" for c in conds) if len(conds) > 1 else conds[0]
                    lines.append(f"        {prefix_b} b == {fb} and ({combined}):")
                    lines.append(f"            return {fmt_ret(ret)}")
                else:
                    lines.append(f"        {prefix_b} b == {fb}:")
                    first_c = True
                    for p in patterns:
                        prefix_c = "if" if first_c else "elif"
                        first_c = False
                        cond = gen_condition(p, "c")
                        lines.append(f"            {prefix_c} {cond}:")
                        lines.append(f"                return {fmt_ret(p.ret)}")

    lines.append("    return Diff(0, 0, 0, 0, 0, 0, 3, 0)")
    return "\n".join(lines)


def generate_4byte(mappings: list[Mapping]) -> str:
    """Generate the 4-byte _to_upper function."""
    lines = []
    lines.append("@always_inline")
    lines.append("def _to_upper(a: UInt8, b: UInt8, c: UInt8, d: UInt8) -> Diff:")
    lines.append('    """Given four bytes of a UTF-8 char, returns byte adjustments for uppercasing.')
    lines.append("    Returns Diff(delta_byte0, delta_byte1, delta_byte2, delta_byte3).")
    lines.append('    """')

    # Group by first byte
    by_first = defaultdict(list)
    for m in mappings:
        by_first[m.src_bytes[0]].append(m)

    first_a = True
    for fa in sorted(by_first.keys()):
        group_a = by_first[fa]
        prefix_a = "if" if first_a else "elif"
        first_a = False
        lines.append(f"    {prefix_a} a == {fa}:")

        # Group by second byte
        by_second = defaultdict(list)
        for m in group_a:
            by_second[m.src_bytes[1]].append(m)

        first_b = True
        for fb in sorted(by_second.keys()):
            group_b = by_second[fb]
            prefix_b = "if" if first_b else "elif"
            first_b = False

            # Group by third byte
            by_third = defaultdict(list)
            for m in group_b:
                by_third[m.src_bytes[2]].append(m)

            if len(by_third) == 1:
                fc = list(by_third.keys())[0]
                group_c = by_third[fc]

                ret_map = {}
                for m in group_c:
                    ret = compute_return_tuple(m, 4)
                    ret_map[m.src_bytes[3]] = ret

                patterns = find_patterns(list(ret_map.keys()), ret_map)

                if len(patterns) == 1:
                    p = patterns[0]
                    cond_d = gen_condition(p, "d")
                    lines.append(f"        {prefix_b} b == {fb} and c == {fc} and {cond_d}:")
                    lines.append(f"            return {fmt_ret(p.ret)}")
                else:
                    all_rets = set(p.ret for p in patterns)
                    if len(all_rets) == 1:
                        ret = patterns[0].ret
                        conds = [gen_condition(p, "d") for p in patterns]
                        combined = " or ".join(f"({c})" for c in conds) if len(conds) > 1 else conds[0]
                        lines.append(f"        {prefix_b} b == {fb} and c == {fc} and ({combined}):")
                        lines.append(f"            return {fmt_ret(ret)}")
                    else:
                        lines.append(f"        {prefix_b} b == {fb} and c == {fc}:")
                        first_d = True
                        for p in patterns:
                            prefix_d = "if" if first_d else "elif"
                            first_d = False
                            cond = gen_condition(p, "d")
                            lines.append(f"            {prefix_d} {cond}:")
                            lines.append(f"                return {fmt_ret(p.ret)}")
            else:
                lines.append(f"        {prefix_b} b == {fb}:")
                first_c = True
                for fc in sorted(by_third.keys()):
                    group_c = by_third[fc]
                    prefix_c = "if" if first_c else "elif"
                    first_c = False

                    ret_map = {}
                    for m in group_c:
                        ret = compute_return_tuple(m, 4)
                        ret_map[m.src_bytes[3]] = ret

                    patterns = find_patterns(list(ret_map.keys()), ret_map)

                    if len(patterns) == 1:
                        p = patterns[0]
                        cond_d = gen_condition(p, "d")
                        lines.append(f"            {prefix_c} c == {fc} and {cond_d}:")
                        lines.append(f"                return {fmt_ret(p.ret)}")
                    else:
                        all_rets = set(p.ret for p in patterns)
                        if len(all_rets) == 1:
                            ret = patterns[0].ret
                            conds = [gen_condition(p, "d") for p in patterns]
                            combined = " or ".join(f"({c})" for c in conds) if len(conds) > 1 else conds[0]
                            lines.append(f"            {prefix_c} c == {fc} and ({combined}):")
                            lines.append(f"                return {fmt_ret(ret)}")
                        else:
                            lines.append(f"            {prefix_c} c == {fc}:")
                            first_d = True
                            for p in patterns:
                                prefix_d = "if" if first_d else "elif"
                                first_d = False
                                cond = gen_condition(p, "d")
                                lines.append(f"                {prefix_d} {cond}:")
                                lines.append(f"                    return {fmt_ret(p.ret)}")

    lines.append("    return Diff(0, 0, 0, 0, 0, 0, 0, 0)")
    return "\n".join(lines)


def generate_main_function() -> str:
    return '''
def upper_utf8(s: String) -> String:
    """Convert a UTF-8 encoded string to uppercase using a decision tree.

    Args:
        s: Input string.

    Returns:
        A new string with all characters converted to uppercase.
    """
    var byte_len = s.byte_length()
    var capacity = byte_len // 2 * 3 + 1
    var result = String(capacity=capacity)
    var buf = result.unsafe_ptr_mut()
    var offset = 0
    var p = s.unsafe_ptr()
    var count = 0
    while offset < byte_len:
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
            buf[0] = (Byte(b0 + _to_upper(b0)))
            buf += 1
            count += 1
        elif char_length == 2:
            var b1 = p[offset + 1]
            var diff = _to_upper(b0, b1)
            var out_len = Int(diff[6])
            buf[0] = Byte(Int16(b0) + diff[0])
            if out_len >= 2:
                buf[1] = (Byte(Int16(b1) + diff[1]))
            if out_len >= 3:
                buf[2] = (Byte(diff[2]))
            if out_len >= 4:
                buf[3] = (Byte(diff[3]))
            if out_len >= 5:
                buf[4] = (Byte(diff[4]))
            if out_len >= 6:
                buf[5] = (Byte(diff[5]))
            buf += out_len
            count += out_len
        elif char_length == 3:
            var b1 = p[offset + 1]
            var b2 = p[offset + 2]
            var diff = _to_upper(b0, b1, b2)
            var out_len = Int(diff[6])
            buf[0] = (Byte(Int16(b0) + diff[0]))
            if out_len >= 2:
                buf[1] = (Byte(Int16(b1) + diff[1]))
            if out_len >= 3:
                buf[2] = (Byte(Int16(b2) + diff[2]))
            if out_len >= 4:
                buf[3] = (Byte(diff[3]))
            if out_len >= 5:
                buf[4] = (Byte(diff[4]))
            if out_len >= 6:
                buf[5] = (Byte(diff[5]))
            buf += out_len
            count += out_len
        elif char_length == 4:
            var b1 = p[offset + 1]
            var b2 = p[offset + 2]
            var b3 = p[offset + 3]
            var diff = _to_upper(b0, b1, b2, b3)
            buf[0] = (Byte(Int16(b0) + diff[0]))
            buf[1] = (Byte(Int16(b1) + diff[1]))
            buf[2] = (Byte(Int16(b2) + diff[2]))
            buf[3] = (Byte(Int16(b3) + diff[3]))
            buf += 4
            count += 4
        offset += char_length
    buf[0] = 0
    result.resize(unsafe_uninit_length=count)
    return result'''


def main():
    csv_file = "to_upper.csv"
    mappings = parse_csv(csv_file)
    by_len = group_by_src_len(mappings)

    print("from std.bit import count_leading_zeros")
    print("from std.memory import alloc, memcpy")
    print()
    print("comptime Diff = SIMD[DType.int16, 8]")
    print()
    print()
    # 1-byte: trivial (UInt8 wraps: -32 mod 256 = 224)
    print("@always_inline")
    print("def _to_upper(a: UInt8) -> UInt8:")
    print('    """Branch-free ASCII uppercase. Returns delta to add to the byte."""')
    print("    var is_lower = (a >= 97) & (a <= 122)")
    print("    return UInt8(is_lower) * 224")
    print()
    print()

    # 2-byte
    print(generate_2byte(by_len.get(2, [])))
    print()
    print()

    # 3-byte
    print(generate_3byte(by_len.get(3, [])))
    print()
    print()

    # 4-byte
    print(generate_4byte(by_len.get(4, [])))
    print()

    # Main function
    print(generate_main_function())
    print()


if __name__ == "__main__":
    main()
