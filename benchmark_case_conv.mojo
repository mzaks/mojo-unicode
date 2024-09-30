from time import now
from csv import CsvTable
from _unicode import to_lowercase, to_uppercase
from text import *
from to_lower import lower_utf8
from utf8_case_conversion import to_lowercase2 as to_lowercase_stree, to_lowercase as to_lowercase_utf8
from benchmark import run
from testing import assert_equal


fn to_lowercase_handwritten(s: String) -> String:
    return lower_utf8(s.unsafe_ptr(), s.byte_length())

fn main() raises:
    # print("Ԟ", to_lowercase("Ԟ"), to_lowercase3("Ԟ"))
    # print(lower_utf8("ᏨMaxim".unsafe_ptr(), "ᏨMaxim".byte_length()))
    # print(to_lowercase3("ᏨMaxim"))
    # print(to_lowercase("Maxim"))
    # print(to_uppercase("Maxim"))
    # print(to_lowercase(text_ru))
    # print(to_uppercase(text_ru))
    # print(to_lowercase(text_de))
    # print(to_uppercase(text_de))

    var sources = List[String]()
    var destinations = List[String]()
    var conversions = List[String]()

    with open("to_lower.csv", "r") as f:
        var csv_string = f.read()
        var table = CsvTable(csv_string)
        for i in range(1, table.row_count()):
            sources.append(table.get(i, 2))
            destinations.append(table.get(i, 7))

    # print(sources.__str__())
    # print(destinations.__str__())
    # print(conversions.__str__())

    @parameter
    fn convert[f: fn(String) -> String]():
        conversions.clear()
        for s in sources:
            conversions.append(f(s[]))
    
    print("Convert every upper case char: (ms)")
    var report = run[convert[to_lowercase_handwritten]]()
    print(str("Handwritten").ljust(20), report.mean("ms"))
    # print(conversions.__str__())


    for i in range(len(conversions)):
        assert_equal(conversions[i], destinations[i])

    report = run[convert[to_lowercase]]()
    print(str("Code point lookup").ljust(20), report.mean("ms"))

    for i in range(len(conversions)):
        assert_equal(conversions[i], destinations[i])

    report = run[convert[to_lowercase_utf8]]()
    print(str("UTF-8 lookup").ljust(20), report.mean("ms"))

    for i in range(len(conversions)):
        assert_equal(conversions[i], destinations[i])

    report = run[convert[to_lowercase_stree]]()
    print(str("UTF-8 STree lookup").ljust(20), report.mean("ms"))

    for i in range(len(conversions)):
        assert_equal(conversions[i], destinations[i])

    _ = sources
    
    var converted: String = ""

    @parameter
    fn convert_text[text: String, f: fn(String) -> String]():
        converted = f(text)

    var expected = to_lowercase(text_ru)
    print("Convert RU text", text_ru.byte_length())
    report = run[convert_text[text_ru, to_lowercase_handwritten]]()
    print(str("Handwritten").ljust(20), report.mean("ms"))
    assert_equal(converted, expected)

    report = run[convert_text[text_ru, to_lowercase]]()
    print(str("Code point lookup").ljust(20), report.mean("ms"))
    assert_equal(converted, expected)

    report = run[convert_text[text_ru, to_lowercase_utf8]]()
    print(str("UTF-8 lookup").ljust(20), report.mean("ms"))
    assert_equal(converted, expected)

    report = run[convert_text[text_ru, to_lowercase_stree]]()
    print(str("UTF-8 STree lookup").ljust(20), report.mean("ms"))
    assert_equal(converted, expected)

    expected = to_lowercase(text_de)
    print("Convert DE text", text_de.byte_length())
    report = run[convert_text[text_de, to_lowercase_handwritten]]()
    print(str("Handwritten").ljust(20), report.mean("ms"))
    assert_equal(converted, expected)

    report = run[convert_text[text_de, to_lowercase]]()
    print(str("Code point lookup").ljust(20), report.mean("ms"))
    assert_equal(converted, expected)

    report = run[convert_text[text_de, to_lowercase_utf8]]()
    print(str("UTF-8 lookup").ljust(20), report.mean("ms"))
    assert_equal(converted, expected)

    report = run[convert_text[text_de, to_lowercase_stree]]()
    print(str("UTF-8 STree lookup").ljust(20), report.mean("ms"))
    assert_equal(converted, expected)
