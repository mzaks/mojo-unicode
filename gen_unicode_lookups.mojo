alias lower_special_2: String = """\
00DF; 00DF; 0053 0073; 0053 0053; LATIN SMALL LETTER SHARP S
FB00; FB00; 0046 0066; 0046 0046; LATIN SMALL LIGATURE FF
FB01; FB01; 0046 0069; 0046 0049; LATIN SMALL LIGATURE FI
FB02; FB02; 0046 006C; 0046 004C; LATIN SMALL LIGATURE FL
FB05; FB05; 0053 0074; 0053 0054; LATIN SMALL LIGATURE LONG S T
FB06; FB06; 0053 0074; 0053 0054; LATIN SMALL LIGATURE ST
0587; 0587; 0535 0582; 0535 0552; ARMENIAN SMALL LIGATURE ECH YIWN
FB13; FB13; 0544 0576; 0544 0546; ARMENIAN SMALL LIGATURE MEN NOW
FB14; FB14; 0544 0565; 0544 0535; ARMENIAN SMALL LIGATURE MEN ECH
FB15; FB15; 0544 056B; 0544 053B; ARMENIAN SMALL LIGATURE MEN INI
FB16; FB16; 054E 0576; 054E 0546; ARMENIAN SMALL LIGATURE VEW NOW
FB17; FB17; 0544 056D; 0544 053D; ARMENIAN SMALL LIGATURE MEN XEH
0149; 0149; 02BC 004E; 02BC 004E; LATIN SMALL LETTER N PRECEDED BY APOSTROPHE
01F0; 01F0; 004A 030C; 004A 030C; LATIN SMALL LETTER J WITH CARON
1E96; 1E96; 0048 0331; 0048 0331; LATIN SMALL LETTER H WITH LINE BELOW
1E97; 1E97; 0054 0308; 0054 0308; LATIN SMALL LETTER T WITH DIAERESIS
1E98; 1E98; 0057 030A; 0057 030A; LATIN SMALL LETTER W WITH RING ABOVE
1E99; 1E99; 0059 030A; 0059 030A; LATIN SMALL LETTER Y WITH RING ABOVE
1E9A; 1E9A; 0041 02BE; 0041 02BE; LATIN SMALL LETTER A WITH RIGHT HALF RING
1F50; 1F50; 03A5 0313; 03A5 0313; GREEK SMALL LETTER UPSILON WITH PSILI
1FB6; 1FB6; 0391 0342; 0391 0342; GREEK SMALL LETTER ALPHA WITH PERISPOMENI
1FC6; 1FC6; 0397 0342; 0397 0342; GREEK SMALL LETTER ETA WITH PERISPOMENI
1FD6; 1FD6; 0399 0342; 0399 0342; GREEK SMALL LETTER IOTA WITH PERISPOMENI
1FE4; 1FE4; 03A1 0313; 03A1 0313; GREEK SMALL LETTER RHO WITH PSILI
1FE6; 1FE6; 03A5 0342; 03A5 0342; GREEK SMALL LETTER UPSILON WITH PERISPOMENI
1FF6; 1FF6; 03A9 0342; 03A9 0342; GREEK SMALL LETTER OMEGA WITH PERISPOMENI
"""

alias lower_special_3: String = """\
FB03; FB03; 0046 0066 0069; 0046 0046 0049; LATIN SMALL LIGATURE FFI
FB04; FB04; 0046 0066 006C; 0046 0046 004C; LATIN SMALL LIGATURE FFL
0390; 0390; 0399 0308 0301; 0399 0308 0301; GREEK SMALL LETTER IOTA WITH DIALYTIKA AND TONOS
03B0; 03B0; 03A5 0308 0301; 03A5 0308 0301; GREEK SMALL LETTER UPSILON WITH DIALYTIKA AND TONOS
1F52; 1F52; 03A5 0313 0300; 03A5 0313 0300; GREEK SMALL LETTER UPSILON WITH PSILI AND VARIA
1F54; 1F54; 03A5 0313 0301; 03A5 0313 0301; GREEK SMALL LETTER UPSILON WITH PSILI AND OXIA
1F56; 1F56; 03A5 0313 0342; 03A5 0313 0342; GREEK SMALL LETTER UPSILON WITH PSILI AND PERISPOMENI
1FD2; 1FD2; 0399 0308 0300; 0399 0308 0300; GREEK SMALL LETTER IOTA WITH DIALYTIKA AND VARIA
1FD3; 1FD3; 0399 0308 0301; 0399 0308 0301; GREEK SMALL LETTER IOTA WITH DIALYTIKA AND OXIA
1FD7; 1FD7; 0399 0308 0342; 0399 0308 0342; GREEK SMALL LETTER IOTA WITH DIALYTIKA AND PERISPOMENI
1FE2; 1FE2; 03A5 0308 0300; 03A5 0308 0300; GREEK SMALL LETTER UPSILON WITH DIALYTIKA AND VARIA
1FE3; 1FE3; 03A5 0308 0301; 03A5 0308 0301; GREEK SMALL LETTER UPSILON WITH DIALYTIKA AND OXIA
1FE7; 1FE7; 03A5 0308 0342; 03A5 0308 0342; GREEK SMALL LETTER UPSILON WITH DIALYTIKA AND PERISPOMENI
"""

from gen_to_lower import hex_to_int


@value
struct Entry(ComparableCollectionElement):
    var rune: Int
    var sub: String
    var info: String

    fn __lt__(self, other: Self) -> Bool:
        return self.rune.__lt__(other.rune)

    fn __le__(self, other: Self) -> Bool:
        return self.rune.__le__(other.rune)

    fn __gt__(self, other: Self) -> Bool:
        return self.rune.__gt__(other.rune)

    fn __ge__(self, other: Self) -> Bool:
        return self.rune.__ge__(other.rune)

    fn __eq__(self, other: Self) -> Bool:
        return self.rune.__eq__(other.rune)

    fn __ne__(self, other: Self) -> Bool:
        return self.rune.__ne__(other.rune)

    fn __repr__(self) -> String:
        return str(self.rune) + ":" + self.sub


def gen_has_uppercase_mapping(unicode_data: String, inout formatter: Formatter):
    gen_lookup["has_uppercase_mapping", 0, 1, 12](unicode_data, formatter)


def gen_has_uppercase_mapping2(
    unicode_data: String, inout formatter: Formatter
):
    gen_lookup["has_uppercase_mapping2", 0, -1, 1](unicode_data, formatter)


def gen_has_uppercase_mapping3(
    unicode_data: String, inout formatter: Formatter
):
    gen_lookup["has_uppercase_mapping3", 0, -1, 1](unicode_data, formatter)


def gen_uppercase_mapping(unicode_data: String, inout formatter: Formatter):
    gen_lookup["uppercase_mapping", 12, 1, 12](unicode_data, formatter)


def gen_has_lowercase_mapping(unicode_data: String, inout formatter: Formatter):
    gen_lookup["has_lowercase_mapping", 0, 1, 13](unicode_data, formatter)


def gen_lowercase_mapping(unicode_data: String, inout formatter: Formatter):
    gen_lookup["lowercase_mapping", 13, 1, 13](unicode_data, formatter)


def gen_lookup[
    name: String,
    rune_column_id: Int,
    description_column_id: Int,
    mapping_column_id: Int,
](unicode_data: String, inout formatter: Formatter):
    formatter.write_str("alias ")
    formatter.write_str(name.as_string_slice())
    formatter.write_str(" = List[UInt32, hint_trivial_type=True](\n")
    for line in unicode_data.splitlines():
        var parts = line[].split(";")
        var rune = "0x" + parts[rune_column_id]
        var mapping = parts[mapping_column_id]
        if len(mapping) > 0:
            formatter.write_str("    ")
            formatter.write_str(rune.as_string_slice())
            formatter.write_str(", # ")
            if rune_column_id == 0:
                formatter.write_str(parts[1].as_string_slice())
                var char = chr(hex_to_int(parts[rune_column_id]))
                formatter.write_str(" ")
                formatter.write_str(char.as_string_slice())
            else:
                var source = chr(hex_to_int(parts[0]))
                formatter.write_str(source.as_string_slice())
                formatter.write_str(" -> ")
                var target = chr(hex_to_int(parts[rune_column_id]))
                formatter.write_str(target.as_string_slice())
            formatter.write_str("\n")

    formatter.write_str(")\n")


def special2(inout formatter: Formatter):
    var runes = List[Entry]()
    for line in lower_special_2.splitlines():
        var parts = line[].split(";")
        runes.append(Entry(hex_to_int(parts[0]), parts[3].strip(), parts[-1]))
    sort(runes)
    formatter.write_str(
        "alias has_uppercase_mapping2 = List[UInt32, hint_trivial_type=True](\n"
    )
    for r in runes:
        formatter.write_str("    ")
        formatter.write_str(hex(r[].rune).upper().as_string_slice())
        formatter.write_str(", # ")
        formatter.write_str(r[].info.as_string_slice())
        var char = chr(r[].rune)
        formatter.write_str(" ")
        formatter.write_str(char.as_string_slice())
        formatter.write_str("\n")

    formatter.write_str(")\n")

    formatter.write_str(
        "alias uppercase_mapping2 = List[SIMD[DType.uint32, 2],"
        " hint_trivial_type=True](\n"
    )
    for r in runes:
        formatter.write_str("    ")
        var parts = r[].sub.split(" ")
        formatter.write_str("SIMD[DType.uint32, 2](")
        formatter.write_str((String("0x") + parts[0]).as_string_slice())
        formatter.write_str(", ")
        formatter.write_str((String("0x") + parts[1]).as_string_slice())
        formatter.write_str(")")
        formatter.write_str(", # ")
        var char = chr(r[].rune)
        formatter.write_str(" ")
        formatter.write_str(char.as_string_slice())
        formatter.write_str(" -> ")
        var char1 = chr(hex_to_int(parts[0]))
        var char2 = chr(hex_to_int(parts[1]))
        formatter.write_str(char1.as_string_slice())
        formatter.write_str(char2.as_string_slice())

        formatter.write_str("\n")

    formatter.write_str(")\n")


def special3(inout formatter: Formatter):
    var runes = List[Entry]()
    for line in lower_special_3.splitlines():
        var parts = line[].split(";")
        runes.append(Entry(hex_to_int(parts[0]), parts[3].strip(), parts[-1]))
    sort(runes)
    formatter.write_str(
        "alias has_uppercase_mapping3 = List[UInt32, hint_trivial_type=True](\n"
    )
    for r in runes:
        formatter.write_str("    ")
        formatter.write_str(hex(r[].rune).upper().as_string_slice())
        formatter.write_str(", # ")
        formatter.write_str(r[].info.as_string_slice())
        var char = chr(r[].rune)
        formatter.write_str(" ")
        formatter.write_str(char.as_string_slice())
        formatter.write_str("\n")

    formatter.write_str(")\n")

    formatter.write_str(
        "alias uppercase_mapping3 = List[SIMD[DType.uint32, 4],"
        " hint_trivial_type=True](\n"
    )
    for r in runes:
        formatter.write_str("    ")
        var parts = r[].sub.split(" ")
        formatter.write_str("SIMD[DType.uint32, 4](")
        formatter.write_str((String("0x") + parts[0]).as_string_slice())
        formatter.write_str(", ")
        formatter.write_str((String("0x") + parts[1]).as_string_slice())
        formatter.write_str(", ")
        formatter.write_str((String("0x") + parts[2]).as_string_slice())
        formatter.write_str(", 0)")
        formatter.write_str(", # ")
        var char = chr(r[].rune)
        formatter.write_str(" ")
        formatter.write_str(char.as_string_slice())
        formatter.write_str(" -> ")
        var char1 = chr(hex_to_int(parts[0]))
        var char2 = chr(hex_to_int(parts[1]))
        var char3 = chr(hex_to_int(parts[2]))
        formatter.write_str(char1.as_string_slice())
        formatter.write_str(char2.as_string_slice())
        formatter.write_str(char3.as_string_slice())

        formatter.write_str("\n")

    formatter.write_str(")\n")


def main():
    with open("Unicode-Data.txt", "r") as f:
        var csv_string = f.read()
        var std = Formatter.stdout()
        gen_has_uppercase_mapping(csv_string, std)
        gen_has_lowercase_mapping(csv_string, std)
        gen_uppercase_mapping(csv_string, std)
        gen_lowercase_mapping(csv_string, std)
        special2(std)
        special3(std)
