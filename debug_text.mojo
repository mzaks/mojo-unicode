from text import text_de, text_en, text_ru, text_lt, text_ch, text_adlam, text_fulflude, text_gr
def main():
    for name, t in [("ru", text_ru), ("de", text_de), ("en", text_en), ("lt", text_lt), ("ch", text_ch), ("adlam", text_adlam), ("fulflude", text_fulflude), ("gr", text_gr)]:
        var b = t.as_bytes()
        print(name, "len=", len(t), "first_bytes=", Int(b[0]), Int(b[1]), Int(b[2]))
