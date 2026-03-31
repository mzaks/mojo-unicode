from to_lower_v2 import lower_utf8 as lower_utf8_v2
from to_lower_v3 import lower_utf8 as lower_utf8_v3
from to_lower_v4 import lower_utf8 as lower_utf8_v4
from to_lower_v5 import lower_utf8 as lower_utf8_v5
from to_lower import lower_utf8
from to_upper import upper_utf8
from to_upper_v2 import upper_utf8 as upper_utf8_v2
from to_upper_v3 import upper_utf8 as upper_utf8_v3
from to_upper_v4 import upper_utf8 as upper_utf8_v4
from text import *
from std.time import perf_counter_ns

def lower(text: String) -> String:
    var sum: UInt = 0
    var lower = ""
    for _ in range(20):
        var start = perf_counter_ns()
        lower = lower_utf8(text.unsafe_ptr(), len(text))
        var end = perf_counter_ns()
        sum += end - start
    # print(lower)
    print(t"In: {(Float64(sum) / 20) / Float64(len(text))} ns per byte")
    return lower


def lower_v2(text: String) -> String:
    var sum: UInt = 0
    var lower = ""
    for _ in range(20):
        var start = perf_counter_ns()
        lower = lower_utf8_v2(text)
        var end = perf_counter_ns()
        sum += end - start
    # print(lower)
    print(t"In: {(Float64(sum) / 20) / Float64(len(text))} ns per byte")
    return lower

def lower_v3(text: String) -> String:
    var sum: UInt = 0
    var lower = ""
    for _ in range(20):
        var start = perf_counter_ns()
        lower = lower_utf8_v3(text)
        var end = perf_counter_ns()
        sum += end - start
    # print(lower)
    print(t"In: {(Float64(sum) / 20) / Float64(len(text))} ns per byte")
    return lower


def lower_v4(text: String) -> String:
    var sum: UInt = 0
    var lower = ""
    for _ in range(20):
        var start = perf_counter_ns()
        lower = lower_utf8_v4(text)
        var end = perf_counter_ns()
        sum += end - start
    # print(lower)
    print(t"In: {(Float64(sum) / 20) / Float64(len(text))} ns per byte")
    return lower


def lower_v5(text: String) -> String:
    var sum: UInt = 0
    var lower = ""
    for _ in range(20):
        var start = perf_counter_ns()
        lower = lower_utf8_v5(text)
        var end = perf_counter_ns()
        sum += end - start
    # print(lower)
    print(t"In: {(Float64(sum) / 20) / Float64(len(text))} ns per byte")
    return lower


def lower_std_lib(text: String) -> String:
    var sum: UInt = 0
    var lower = ""
    for _ in range(20):
        var start = perf_counter_ns()
        lower = text.lower()
        var end = perf_counter_ns()
        sum += end - start
    # print(lower)
    print(t"In: {(Float64(sum) / 20) / Float64(len(text))} ns per byte")
    return lower

def upper(text: String) -> String:
    var sum: UInt = 0
    var upper = ""
    for _ in range(20):
        var start = perf_counter_ns()
        upper = upper_utf8(text)
        var end = perf_counter_ns()
        sum += end - start
    # print(lower)
    print(t"In: {(Float64(sum) / 20) / Float64(len(text))} ns per byte")
    return upper

def upper_v2(text: String) -> String:
    var sum: UInt = 0
    var upper = ""
    for _ in range(20):
        var start = perf_counter_ns()
        upper = upper_utf8_v2(text)
        var end = perf_counter_ns()
        sum += end - start
    # print(upper)
    print(t"In: {(Float64(sum) / 20) / Float64(len(text))} ns per byte")
    return upper


def upper_v3(text: String) -> String:
    var sum: UInt = 0
    var upper = ""
    for _ in range(20):
        var start = perf_counter_ns()
        upper = upper_utf8_v3(text)
        var end = perf_counter_ns()
        sum += end - start
    # print(upper)
    print(t"In: {(Float64(sum) / 20) / Float64(len(text))} ns per byte")
    return upper


def upper_v4(text: String) -> String:
    var sum: UInt = 0
    var upper = ""
    for _ in range(20):
        var start = perf_counter_ns()
        upper = upper_utf8_v4(text)
        var end = perf_counter_ns()
        sum += end - start
    # print(upper)
    print(t"In: {(Float64(sum) / 20) / Float64(len(text))} ns per byte")
    return upper


def upper_std_lib(text: String) -> String:
    var sum: UInt = 0
    var upper = ""
    for _ in range(20):
        var start = perf_counter_ns()
        upper = text.upper()
        var end = perf_counter_ns()
        sum += end - start
    # print(lower)
    print(t"In: {(Float64(sum) / 20) / Float64(len(text))} ns per byte")
    return upper

def main():
    for t in [(text_ru, "RU"), (text_de, "DE"), (text_en, "EN"), (text_lt, "LT"), (text_gr, "GR"), (text_adlam, "Adlam"), (text_fulflude, "Fulflude"), (text_ch, "CH")]:
        _ = lower(t[0])
        print("Lower", t[1], "-" * 20)
        _ = lower_v2(t[0])
        print("Lower v2", t[1], "-" * 20)
        _ = lower_v3(t[0])
        print("Lower v3", t[1], "-" * 20)
        _ = lower_v4(t[0])
        print("Lower v4", t[1], "-" * 20)
        _ = lower_v5(t[0])
        print("Lower v5", t[1], "-" * 20)
        _ = lower_std_lib(t[0])
        print("Lower std", t[1], "-" * 20)
        _ = upper(t[0])
        print("Upper", t[1], "-" * 20)
        _ = upper_v2(t[0])
        print("Upper v2", t[1], "-" * 20)
        _ = upper_v3(t[0])
        print("Upper v3", t[1], "-" * 20)
        _ = upper_v4(t[0])
        print("Upper v4", t[1], "-" * 20)
        _ = upper_std_lib(t[0])
        print("Upper std", t[1], "-" * 20)
