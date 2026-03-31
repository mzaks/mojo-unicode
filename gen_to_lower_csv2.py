import csv


def push_bytes(s: str) -> str:
    return " ".join(str(b) for b in s.encode("utf-8"))


def push_diff_bytes(s: str, sd: str) -> str:
    sb = s.encode("utf-8")
    sdb = sd.encode("utf-8")
    length = max(len(sb), len(sdb))
    return " ".join(
        str((sdb[i] if i < len(sdb) else 0) ^ (sb[i] if i < len(sb) else 0))
        for i in range(length)
    )


def main():
    rows = []

    with open("Unicode-Data.txt", "r", encoding="utf-8") as f:
        reader = csv.reader(f, delimiter=";")
        for row in reader:
            if len(row) <= 13:
                continue
            lower = row[13].strip()
            if not lower:
                continue

            source_hex = row[0].strip()
            source_int = int(source_hex, 16)
            c = chr(source_int)
            source_bytes = push_bytes(c)

            dest_int = int(lower, 16)
            cu = chr(dest_int)
            dest_bytes = push_bytes(cu)

            diff = dest_int - source_int
            if diff == 0:
                continue
            diff_bytes = push_diff_bytes(c, cu)

            rows.append([
                source_hex,
                source_int,
                c,
                len(c.encode("utf-8")),
                source_bytes,
                lower,
                dest_int,
                cu,
                len(cu.encode("utf-8")),
                dest_bytes,
                diff,
                diff_bytes,
            ])

    with open("to_lower3.csv", "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow([
            "source hex", "source int", "source", "source len", "source bytes",
            "destination hex", "destination int", "destination", "destination len",
            "destination bytes", "diff", "diff bytes",
        ])
        writer.writerows(rows)


if __name__ == "__main__":
    main()
