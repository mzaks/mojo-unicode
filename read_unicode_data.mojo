from csv import CsvTable, CsvBuilder


fn hex_to_int(value: String) -> Int:
    var multiplicator = 1
    var result = 0
    for i in range(len(value), 0, -1):
        var c = ord(value[i - 1]) - 0x30
        if c > 10:
            c -= 7
        result += c * multiplicator
        multiplicator *= 16
    return result


fn push_bytes(s: String, inout builder: CsvBuilder):
    var ints: String = ""
    for b in s.as_bytes():
        ints += String(b[].cast[DType.uint8]())
        ints += " "
    builder.push(ints, False)


fn push_diff_bytes(s: String, sd: String, inout builder: CsvBuilder):
    var ints: String = ""
    for i in range(len(s.as_bytes())):
        var b = s.as_bytes()[i].cast[DType.uint8]()
        var d = sd.as_bytes()[i].cast[DType.uint8]()
        ints += str(int(d) - int(b))
        ints += " "
    builder.push(ints, False)


fn main() raises:
    var conversions = CsvBuilder(
        "source hex",
        "source int",
        "source",
        "source len",
        "source bytes",
        "destination hex",
        "destination int",
        "destination",
        "destination len",
        "destination bytes",
        "diff",
        "diff bytes",
    )
    with open("Unicode-Data.txt", "r") as f:
        var csv_string = f.read()
        # print(csv_string)
        var table = CsvTable[sep = ord(";")](csv_string)
        for i in range(table.row_count()):
            var upper = table.get(i, 14)
            if len(upper) > 0:
                conversions.push(table.get(i, 0), False)
                conversions.push(hex_to_int(table.get(i, 0)))
                var c = chr(hex_to_int(table.get(i, 0)))
                conversions.push(c, False)
                conversions.push(len(c))
                push_bytes(c, conversions)
                conversions.push(upper, False)
                conversions.push(hex_to_int(upper))
                var cu = chr(hex_to_int(upper))
                conversions.push(cu, False)
                conversions.push(len(cu))
                push_bytes(cu, conversions)
                conversions.push(
                    hex_to_int(upper) - hex_to_int(table.get(i, 0))
                )
                push_diff_bytes(c, cu, conversions)
    with open("to_lower.csv", "w") as f:
        f.write(conversions^.finish())
