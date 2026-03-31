#!/usr/bin/env python3
"""Generate to_upper_v4.mojo with lookup-table optimization for 2-byte chars.

For 2-byte UTF-8 chars the entire per-second-byte decision tree is replaced
by a flat (a, b) indexed byte table + a small diff-value dispatch function.
This reduces per-character branches from ~10-15 to 1 (range check on a).

3-byte and 4-byte chars keep the XOR-based decision tree from v3.

Usage:
    python3 gen_to_upper_tree_v3.py > to_upper_v4.mojo
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
        next(reader)
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
    """XOR-based return tuple (same layout as gen_to_upper_tree_v2.py)."""
    db = m.diff_bytes

    if src_len == 1:
        return (32,)

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


def fmt_ret(ret: tuple) -> str:
    return f"Diff({', '.join(str(x) for x in ret)})"


# ── Lookup-table 2-byte generator ────────────────────────────────────────────

def generate_2byte_lookup(mappings: list[Mapping]) -> str:
    """Replace the per-b if/elif chain with per-a SIMD[DType.uint8, 64] constants.

    For each distinct first byte `a`, one 64-entry SIMD vector maps (b-128) to
    a diff index.  The _to_upper function dispatches on `a` (predictable) then
    does a single SIMD element extraction for `b` — no per-byte branches.

    _u2_diff turns the dense integer diff-index into a concrete Diff value;
    LLVM compiles this if/elif chain into a jump table automatically.
    """
    ab_to_ret = {}
    for m in mappings:
        ret = compute_return_tuple(m, 2)
        ab_to_ret[(m.src_bytes[0], m.src_bytes[1])] = ret

    a_values = sorted({m.src_bytes[0] for m in mappings})
    a_min, a_max = a_values[0], a_values[-1]

    identity = (0, 0, 0, 0, 0, 0, 2, 0)
    unique_rets = [identity]
    ret_to_idx = {identity: 0}
    for ret in sorted(set(ab_to_ret.values())):
        if ret not in ret_to_idx:
            ret_to_idx[ret] = len(unique_rets)
            unique_rets.append(ret)

    lines = []

    # One SIMD[DType.uint8, 64] per a value in the range
    for a in range(a_min, a_max + 1):
        row = [0] * 64
        for b in range(128, 192):
            ret = ab_to_ret.get((a, b))
            if ret is not None:
                row[b - 128] = ret_to_idx[ret]
        vals = ", ".join(str(v) for v in row)
        lines.append(f"comptime _lut_{a} = SIMD[DType.uint8, 64]({vals})")
    lines.append("")

    # _u2_diff: diff_idx → Diff  (LLVM compiles dense int switch to jump table)
    lines.append("@always_inline")
    lines.append("def _u2_diff(i: UInt8) -> Diff:")
    for i, diff in enumerate(unique_rets):
        kw = "if" if i == 0 else "elif"
        lines.append(f"    {kw} i == {i}:")
        lines.append(f"        return {fmt_ret(diff)}")
    lines.append("    return Diff(0, 0, 0, 0, 0, 0, 2, 0)")
    lines.append("")

    # 2-byte _to_upper: dispatch on a (predictable), SIMD extract on b (no branch)
    lines.append("@always_inline")
    lines.append("def _to_upper(a: UInt8, b: UInt8) -> Diff:")
    lines.append('    """Two-byte uppercase: per-a SIMD lookup, no per-byte branches."""')
    lines.append("    var j = Int(b) - 128")
    first = True
    for a in range(a_min, a_max + 1):
        kw = "if" if first else "elif"
        first = False
        lines.append(f"    {kw} a == {a}:")
        lines.append(f"        return _u2_diff(_lut_{a}[j])")
    lines.append("    return Diff(0, 0, 0, 0, 0, 0, 2, 0)")

    return "\n".join(lines)


# ── Tree-based 3-byte and 4-byte generators (identical to v2) ─────────────────

@dataclass
class RangeGroup:
    lo: int
    hi: int
    ret: tuple
    even_only: bool = False
    odd_only: bool = False


def find_contiguous_sub_ranges(vals: list[int], step: int = 1) -> list[tuple[int, int]]:
    if not vals:
        return []
    ranges = []
    start = prev = vals[0]
    for v in vals[1:]:
        if v == prev + step:
            prev = v
        else:
            ranges.append((start, prev))
            start = prev = v
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
            if hi - lo + 1 >= 3:
                patterns.append(RangeGroup(lo, hi, ret))
                handled.update(range(lo, hi + 1))

        remaining = [v for v in vals if v not in handled]
        even_vals = sorted(v for v in remaining if v % 2 == 0)
        odd_vals  = sorted(v for v in remaining if v % 2 == 1)

        for lo, hi in find_contiguous_sub_ranges(even_vals, step=2):
            if (hi - lo) // 2 + 1 >= 3:
                patterns.append(RangeGroup(lo, hi, ret, even_only=True))
                handled.update(range(lo, hi + 1, 2))

        for lo, hi in find_contiguous_sub_ranges(odd_vals, step=2):
            if (hi - lo) // 2 + 1 >= 3:
                patterns.append(RangeGroup(lo, hi, ret, odd_only=True))
                handled.update(range(lo, hi + 1, 2))

        for v in vals:
            if v not in handled:
                patterns.append(RangeGroup(v, v, ret))

    patterns.sort(key=lambda p: p.lo)
    return patterns


def gen_condition(p: RangeGroup, var_name: str) -> str:
    if p.lo == p.hi:
        base = f"{var_name} == {p.lo}"
    else:
        base = f"{var_name} >= {p.lo} and {var_name} <= {p.hi}"
    if p.even_only and p.lo != p.hi:
        return f"{base} and {var_name} & 1 == 0"
    if p.odd_only and p.lo != p.hi:
        return f"{base} and {var_name} & 1 == 1"
    return base


def generate_3byte(mappings: list[Mapping]) -> str:
    lines = []
    lines.append("@always_inline")
    lines.append("def _to_upper(a: UInt8, b: UInt8, c: UInt8) -> Diff:")
    lines.append('    """Three-byte uppercase XOR decision tree."""')

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
                cond_c = gen_condition(patterns[0], "c")
                lines.append(f"        {prefix_b} b == {fb} and {cond_c}:")
                lines.append(f"            return {fmt_ret(patterns[0].ret)}")
            else:
                all_rets = set(p.ret for p in patterns)
                if len(all_rets) == 1:
                    conds = [gen_condition(p, "c") for p in patterns]
                    combined = " or ".join(f"({c})" for c in conds) if len(conds) > 1 else conds[0]
                    lines.append(f"        {prefix_b} b == {fb} and ({combined}):")
                    lines.append(f"            return {fmt_ret(patterns[0].ret)}")
                else:
                    lines.append(f"        {prefix_b} b == {fb}:")
                    first_c = True
                    for p in patterns:
                        prefix_c = "if" if first_c else "elif"
                        first_c = False
                        lines.append(f"            {prefix_c} {gen_condition(p, 'c')}:")
                        lines.append(f"                return {fmt_ret(p.ret)}")

    lines.append("    return Diff(0, 0, 0, 0, 0, 0, 3, 0)")
    return "\n".join(lines)


def generate_4byte(mappings: list[Mapping]) -> str:
    lines = []
    lines.append("@always_inline")
    lines.append("def _to_upper(a: UInt8, b: UInt8, c: UInt8, d: UInt8) -> Diff:")
    lines.append('    """Four-byte uppercase XOR decision tree."""')

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
                ret_map = {m.src_bytes[3]: compute_return_tuple(m, 4) for m in group_c}
                patterns = find_patterns(list(ret_map.keys()), ret_map)

                if len(patterns) == 1:
                    p = patterns[0]
                    lines.append(f"        {prefix_b} b == {fb} and c == {fc} and {gen_condition(p, 'd')}:")
                    lines.append(f"            return {fmt_ret(p.ret)}")
                else:
                    all_rets = set(p.ret for p in patterns)
                    if len(all_rets) == 1:
                        conds = [gen_condition(p, "d") for p in patterns]
                        combined = " or ".join(f"({c})" for c in conds) if len(conds) > 1 else conds[0]
                        lines.append(f"        {prefix_b} b == {fb} and c == {fc} and ({combined}):")
                        lines.append(f"            return {fmt_ret(patterns[0].ret)}")
                    else:
                        lines.append(f"        {prefix_b} b == {fb} and c == {fc}:")
                        first_d = True
                        for p in patterns:
                            prefix_d = "if" if first_d else "elif"
                            first_d = False
                            lines.append(f"            {prefix_d} {gen_condition(p, 'd')}:")
                            lines.append(f"                return {fmt_ret(p.ret)}")
            else:
                lines.append(f"        {prefix_b} b == {fb}:")
                first_c = True
                for fc in sorted(by_third.keys()):
                    group_c = by_third[fc]
                    prefix_c = "if" if first_c else "elif"
                    first_c = False
                    ret_map = {m.src_bytes[3]: compute_return_tuple(m, 4) for m in group_c}
                    patterns = find_patterns(list(ret_map.keys()), ret_map)

                    if len(patterns) == 1:
                        p = patterns[0]
                        lines.append(f"            {prefix_c} c == {fc} and {gen_condition(p, 'd')}:")
                        lines.append(f"                return {fmt_ret(p.ret)}")
                    else:
                        all_rets = set(p.ret for p in patterns)
                        if len(all_rets) == 1:
                            conds = [gen_condition(p, "d") for p in patterns]
                            combined = " or ".join(f"({c})" for c in conds) if len(conds) > 1 else conds[0]
                            lines.append(f"            {prefix_c} c == {fc} and ({combined}):")
                            lines.append(f"                return {fmt_ret(patterns[0].ret)}")
                        else:
                            lines.append(f"            {prefix_c} c == {fc}:")
                            first_d = True
                            for p in patterns:
                                prefix_d = "if" if first_d else "elif"
                                first_d = False
                                lines.append(f"                {prefix_d} {gen_condition(p, 'd')}:")
                                lines.append(f"                    return {fmt_ret(p.ret)}")

    lines.append("    return Diff(0, 0, 0, 0, 0, 0, 0, 0)")
    return "\n".join(lines)


def generate_main_function() -> str:
    return '''
def upper_utf8(s: String) -> String:
    """Convert a UTF-8 string to uppercase.
    Uses an 8-byte SIMD fast path for ASCII runs, lookup table for 2-byte chars.
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

    print("@always_inline")
    print("def _to_upper(a: UInt8) -> UInt8:")
    print('    """Branch-free ASCII uppercase. Returns XOR mask (32 for a-z, 0 otherwise)."""')
    print("    var is_lower = (a >= 97) & (a <= 122)")
    print("    return UInt8(is_lower) * 32")
    print()
    print()

    print(generate_2byte_lookup(by_len.get(2, [])))
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
