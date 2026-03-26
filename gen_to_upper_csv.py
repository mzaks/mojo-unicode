import csv


def push_bytes(s: str) -> str:
    return " ".join(str(b) for b in s.encode("utf-8"))


def push_diff_bytes(s: str, sd: str) -> str:
    sb = s.encode("utf-8")
    sdb = sd.encode("utf-8")
    return " ".join(str(sdb[i] - (sb[i] if i < len(sb) else 0)) for i in range(len(sdb)))


def load_special_cases(col_index: int) -> dict:
    """Load unconditional, non-locale special cases from Special-Casing.txt.
    col_index: 1=lower, 2=title, 3=upper
    Returns dict: {SOURCE_HEX: [dest_hex1, ...]}
    """
    special = {}
    with open("Special-Casing.txt", "r", encoding="utf-8") as f:
        for line in f:
            line = line.split("#")[0].strip()
            if not line:
                continue
            parts = [p.strip() for p in line.split(";")]
            if len(parts) < 4:
                continue
            cond = parts[4].strip() if len(parts) >= 5 else ""
            if cond and any(t.isalpha() and t.islower() for t in cond.split()):
                continue  # skip locale-dependent
            dest_field = parts[col_index]
            if not dest_field:
                continue
            special[parts[0].upper()] = dest_field.split()
    return special


def build_row(source_hex: str, dest_hexes: list) -> list | None:
    source_int = int(source_hex, 16)
    c = chr(source_int)
    source_bytes_str = push_bytes(c)
    source_len = len(c.encode("utf-8"))

    dest_ints = [int(h, 16) for h in dest_hexes]
    dest_str = "".join(chr(i) for i in dest_ints)
    dest_bytes_str = push_bytes(dest_str)
    dest_len = len(dest_str.encode("utf-8"))
    diff_bytes = push_diff_bytes(c, dest_str)

    if len(dest_ints) == 1:
        diff = dest_ints[0] - source_int
        if diff == 0:
            return None
        dest_hex_str = dest_hexes[0]
        dest_int_str = str(dest_ints[0])
    else:
        diff = ""
        dest_hex_str = " ".join(dest_hexes)
        dest_int_str = " ".join(str(i) for i in dest_ints)

    return [
        source_hex, source_int, c, source_len, source_bytes_str,
        dest_hex_str, dest_int_str, dest_str, dest_len, dest_bytes_str,
        diff, diff_bytes,
    ]


def main():
    special_cases = load_special_cases(3)  # 3 = uppercase column
    processed = set()
    rows = []

    with open("Unicode-Data.txt", "r", encoding="utf-8") as f:
        reader = csv.reader(f, delimiter=";")
        for row in reader:
            if len(row) <= 14:
                continue
            source_hex = row[0].strip().upper()

            if source_hex in special_cases:
                dest_hexes = special_cases[source_hex]
            else:
                upper = row[14].strip()
                if not upper:
                    continue
                dest_hexes = [upper]

            result = build_row(source_hex, dest_hexes)
            if result is not None:
                rows.append(result)
            processed.add(source_hex)

    # Add special cases for characters not present in UnicodeData
    for source_hex, dest_hexes in sorted(special_cases.items()):
        if source_hex in processed:
            continue
        result = build_row(source_hex, dest_hexes)
        if result is not None:
            rows.append(result)

    rows.sort(key=lambda r: r[1])  # sort by source_int

    with open("to_upper.csv", "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow([
            "source hex", "source int", "source", "source len", "source bytes",
            "destination hex", "destination int", "destination", "destination len",
            "destination bytes", "diff", "diff bytes",
        ])
        writer.writerows(rows)


if __name__ == "__main__":
    main()
