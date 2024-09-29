from time import now
from csv import CsvTable
from _unicode import to_lowercase, to_uppercase
from text import *
from to_lower import lower_utf8
from utf8_case_conversion import to_lowercase2 as to_lowercase_stree, to_lowercase as to_lowercase_utf8


def main():
    # print("Ԟ", to_lowercase("Ԟ"), to_lowercase3("Ԟ"))
    # print(lower_utf8("ᏨMaxim".unsafe_ptr(), "ᏨMaxim".byte_length()))
    # print(to_lowercase3("ᏨMaxim"))
    # print(to_lowercase("Maxim"))
    # print(to_uppercase("Maxim"))
    # print(to_lowercase(text_ru))
    # print(to_uppercase(text_ru))
    # print(to_lowercase(text_de))
    # print(to_uppercase(text_de))

    with open("to_lower.csv", "r") as f:
        var csv_string = f.read()
        # print(csv_string)
        var table = CsvTable(csv_string)
        var check = 0
        var start = now()
        for i in range(1, table.row_count()):
            var source = table.get(i, 2)
            var dest = table.get(i, 7)
            var conv = to_lowercase(source)
            if conv != dest:
                print("!!!!", i, table.get(i, 1), source, conv, dest)
            else:
                check += 1
        var duration = now() - start
        print("lookup checked      ", check, "in", duration)

    with open("to_lower.csv", "r") as f:
        var csv_string = f.read()
        # print(csv_string)
        var table = CsvTable(csv_string)
        var check = 0
        var start = now()
        for i in range(1, table.row_count()):
            var source = table.get(i, 2)
            var dest = table.get(i, 7)
            var conv = to_lowercase_utf8(source)
            if conv != dest:
                print("!!!!", i, table.get(i, 1), source, conv, dest)
            else:
                check += 1
        var duration = now() - start
        print("lookup utf8 checked ", check, "in", duration)

    with open("to_lower.csv", "r") as f:
        var csv_string = f.read()
        # print(csv_string)
        var table = CsvTable(csv_string)
        var check = 0
        var start = now()
        for i in range(1, table.row_count()):
            var source = table.get(i, 2)
            var dest = table.get(i, 7)
            var conv = to_lowercase_stree(source)
            if conv != dest:
                print("!!!!", i, table.get(i, 1), source, conv, dest)
            else:
                check += 1
        var duration = now() - start
        print("lookup stree checked", check, "in", duration)

    with open("to_lower.csv", "r") as f:
        var csv_string = f.read()
        # print(csv_string)
        var table = CsvTable(csv_string)
        var check = 0
        var start = now()
        for i in range(1, table.row_count()):
            var source = table.get(i, 2)
            var dest = table.get(i, 7)
            var conv = lower_utf8(source.unsafe_ptr(), source.byte_length())
            if conv != dest:
                print("!!!!", i, table.get(i, 1), source, conv, dest)
            else:
                check += 1
        var duration = now() - start
        print("handwritten checked ", check, "in", duration)

    var rounds = 20
    var sum1 = 0
    var duration = 0
    var start = now()
    for _ in range(rounds):
        sum1 += to_lowercase(text_ru).byte_length()
    duration = now() - start
    print("RU to lower lookup      ", duration / rounds)

    var sum2 = 0
    start = now()
    for _ in range(rounds):
        sum2 += to_lowercase_utf8(text_ru).byte_length()
    duration = now() - start
    print("RU to lower lookup utf8 ", duration / rounds)

    sum2 = 0
    start = now()
    for _ in range(rounds):
        sum2 += to_lowercase_stree(text_ru).byte_length()
    duration = now() - start
    print("RU to lower lookup stree", duration / rounds)

    var sum3 = 0
    start = now()
    for _ in range(rounds):
        sum3 += lower_utf8(text_ru.unsafe_ptr(), text_ru.byte_length()).byte_length()
    duration = now() - start
    print("RU to lower handwritten ", duration / rounds)
    print(sum1 / rounds, sum2 / rounds, sum3 / rounds)

    sum1 = 0
    start = now()
    for _ in range(rounds):
        sum1 += to_lowercase(text_de).byte_length()
    duration = now() - start
    print("DE to lower lookup      ", duration / rounds)

    sum2 = 0
    start = now()
    for _ in range(rounds):
        sum2 += to_lowercase_utf8(text_de).byte_length()
    duration = now() - start
    print("DE to lower lookup utf8 ", duration / rounds)

    sum2 = 0
    start = now()
    for _ in range(rounds):
        sum2 += to_lowercase_stree(text_de).byte_length()
    duration = now() - start
    print("DE to lower lookup stree", duration / rounds)

    sum3 = 0
    start = now()
    for _ in range(rounds):
        sum3 += lower_utf8(text_de.unsafe_ptr(), text_de.byte_length()).byte_length()
    duration = now() - start
    print("DE to lower handwritten ", duration / rounds)
    print(sum1 / rounds, sum2 / rounds, sum3 / rounds)
