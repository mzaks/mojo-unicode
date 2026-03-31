#!/usr/bin/env python3
"""Generate a Mojo decision-tree to_upper implementation from to_upper2.csv.

Uses XOR-based byte adjustments instead of addition, allowing Diff to be
SIMD[DType.uint8, 8] with no casts required in the generated Mojo code.

Usage:
    python3 gen_to_upper_tree_v2.py > to_upper_v3.mojo
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
    """Compute the 8-element XOR return tuple for a mapping.

    Layout (SIMD[DType.uint8, 8]):
      2-byte: (xor0, xor1, extra2, extra3, extra4, extra5, out_len, 0)
      3-byte: (xor0, xor1, xor2, extra3, extra4, extra5, out_len, 0)
      4-byte: (xor0, xor1, xor2, xor3, 0, 0, 0, 0)

    xorN = src_byte[N] ^ dst_byte[N]  (XOR mask to apply to source byte)
    extraN = absolute dst byte beyond src_len (XOR mask with implicit 0, so same value)
    out_len = number of output bytes (uint8, fits 1-6)
    """
    db = m.diff_bytes  # already XOR values from to_upper2.csv

    if src_len == 1:
        return (32,)  # XOR with 0x20 converts a-z to A-Z

    if src_len == 2:
        x0 = db[0] if len(db) > 0 else 0
        x1 = db[1] if len(db) > 1 else 0
        extra = [db[i] if len(db) > i else 0 for i in range(2, 6)]
        return (x0, x1, extra[0], extra[1], extra[2], extra[3], m.dst_len, 0)

    if src_len == 3:
        x0 = db[0] if len(db) > 0 else 0
        x1 = db[1] if len(db) > 1 else 0
        x2 = db[2] if len(db) > 2 else 0
        extra = [db[i] if len(db) > i else 0 for i in range(3, 6)]
        return (x0, x1, x2, extra[0], extra[1], extra[2], m.dst_len, 0)

    if src_len == 4:
        x0 = db[0] if len(db) > 0 else 0
        x1 = db[1] if len(db) > 1 else 0
        x2 = db[2] if len(db) > 2 else 0
        x3 = db[3] if len(db) > 3 else 0
        return (x0, x1, x2, x3, 0, 0, 0, 0)

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
    if not byte_values:
        return []

    by_ret = defaultdict(list)
    for bv in sorted(byte_values):
        by_ret[ret_map[bv]].append(bv)

    patterns = []
    for ret, vals in sorted(by_ret.items(), key=lambda x: x[1][0]):
        vals = sorted(vals)
        handled = set()

        for lo, hi in find_contiguous_sub_ranges(vals, step=1):
            count = hi - lo + 1
            if count >= 3:
                patterns.append(RangeGroup(lo, hi, ret))
                handled.update(range(lo, hi + 1))

        remaining = sorted(v for v in vals if v not in handled)
        even_vals = sorted(v for v in remaining if v % 2 == 0)
        odd_vals = sorted(v for v in remaining if v % 2 == 1)

        for lo, hi in find_contiguous_sub_ranges(even_vals, step=2):
            count = (hi - lo) // 2 + 1
            if count >= 3:
                patterns.append(RangeGroup(lo, hi, ret, even_only=True))
                handled.update(range(lo, hi + 1, 2))

        for lo, hi in find_contiguous_sub_ranges(odd_vals, step=2):
            count = (hi - lo) // 2 + 1
            if count >= 3:
                patterns.append(RangeGroup(lo, hi, ret, odd_only=True))
                handled.update(range(lo, hi + 1, 2))

        for v in vals:
            if v not in handled:
                patterns.append(RangeGroup(v, v, ret))

    patterns.sort(key=lambda p: p.lo)
    return patterns


def fmt_ret(ret: tuple) -> str:
    return f"Diff({', '.join(str(x) for x in ret)})"


def gen_condition(p: RangeGroup, var_name: str) -> str:
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
    lines = []
    lines.append("@always_inline")
    lines.append("def _to_upper(a: UInt8, b: UInt8) -> Diff:")
    lines.append('    """Given two bytes of a UTF-8 char, returns XOR masks for uppercasing.')
    lines.append("    Returns Diff(xor_byte0, xor_byte1, extra2..5, output_len, 0).")
    lines.append('    """')

    by_first = defaultdict(list)
    for m in mappings:
        by_first[m.src_bytes[0]].append(m)

    first = True
    for fb in sorted(by_first.keys()):
        group = by_first[fb]
        prefix = "if" if first else "elif"
        first = False

        lines.append(f"    {prefix} a == {fb}:")

        ret_map = {}
        for m in group:
            ret = compute_return_tuple(m, 2)
            ret_map[m.src_bytes[1]] = ret

        patterns = find_patterns(list(ret_map.keys()), ret_map)

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
    lines = []
    lines.append("@always_inline")
    lines.append("def _to_upper(a: UInt8, b: UInt8, c: UInt8) -> Diff:")
    lines.append('    """Given three bytes of a UTF-8 char, returns XOR masks for uppercasing.')
    lines.append("    Returns Diff(xor_byte0, xor_byte1, xor_byte2, extra3..5, output_len, 0).")
    lines.append('    """')

    by_first = defaultdict(list)
    for m in mappings:
        by_first[m.src_bytes[0]].append(m)

    first_a = True
    for fa in sorted(by_first.keys()):
        group_a = by_first[fa]
        prefix_a = "if" if first_a else "elif"
        first_a = False
        lines.append(f"    {prefix_a} a == {fa}:")

        by_second = defaultdict(list)
        for m in group_a:
            by_second[m.src_bytes[1]].append(m)

        first_b = True
        for fb in sorted(by_second.keys()):
            group_b = by_second[fb]
            prefix_b = "if" if first_b else "elif"
            first_b = False

            ret_map = {}
            for m in group_b:
                ret = compute_return_tuple(m, 3)
                ret_map[m.src_bytes[2]] = ret

            patterns = find_patterns(list(ret_map.keys()), ret_map)

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
    lines = []
    lines.append("@always_inline")
    lines.append("def _to_upper(a: UInt8, b: UInt8, c: UInt8, d: UInt8) -> Diff:")
    lines.append('    """Given four bytes of a UTF-8 char, returns XOR masks for uppercasing.')
    lines.append("    Returns Diff(xor_byte0, xor_byte1, xor_byte2, xor_byte3, 0, 0, 0, 0).")
    lines.append('    """')

    by_first = defaultdict(list)
    for m in mappings:
        by_first[m.src_bytes[0]].append(m)

    first_a = True
    for fa in sorted(by_first.keys()):
        group_a = by_first[fa]
        prefix_a = "if" if first_a else "elif"
        first_a = False
        lines.append(f"    {prefix_a} a == {fa}:")

        by_second = defaultdict(list)
        for m in group_a:
            by_second[m.src_bytes[1]].append(m)

        first_b = True
        for fb in sorted(by_second.keys()):
            group_b = by_second[fb]
            prefix_b = "if" if first_b else "elif"
            first_b = False

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
            buf[0] = b0 ^ _to_upper(b0)
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
    return result'''


def main():
    csv_file = "to_upper2.csv"
    mappings = parse_csv(csv_file)
    by_len = group_by_src_len(mappings)

    print("from std.bit import count_leading_zeros")
    print()
    print("comptime Diff = SIMD[DType.uint8, 8]")
    print()
    print()
    # 1-byte: XOR with 0x20 (32) converts a-z to A-Z
    print("@always_inline")
    print("def _to_upper(a: UInt8) -> UInt8:")
    print('    """Branch-free ASCII uppercase. Returns XOR mask (32 for a-z, 0 otherwise)."""')
    print("    var is_lower = (a >= 97) & (a <= 122)")
    print("    return UInt8(is_lower) * 32")
    print()
    print()

    print(generate_2byte(by_len.get(2, [])))
    print()
    print()

    print(generate_3byte(by_len.get(3, [])))
    print()
    print()

    print(generate_4byte(by_len.get(4, [])))
    print()

    print(generate_main_function())
    print()


if __name__ == "__main__":
    main()
