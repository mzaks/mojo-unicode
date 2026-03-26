from std.memory import memcpy, alloc
from .string_utils import find_indices, contains_any_of, string_from_pointer

comptime CR_CHAR = "\r"
comptime CR = UInt8(ord(CR_CHAR))
comptime LF_CHAR = "\n"
comptime LF = UInt8(ord(LF_CHAR))
comptime COMMA_CHAR = ","
comptime COMMA = UInt8(ord(COMMA_CHAR))
comptime QUOTE_CHAR = '"'
comptime QUOTE = UInt8(ord(QUOTE_CHAR))


struct CsvBuilder:
    var _buffer: UnsafePointer[UInt8, MutExternalOrigin]
    var _capacity: Int
    var num_bytes: Int
    var _column_count: Int
    var _elements_count: Int
    var _finished: Bool

    def __init__(out self, column_count: Int):
        self._capacity = 1024
        self._buffer = alloc[UInt8](self._capacity)
        self._column_count = column_count
        self._elements_count = 0
        self._finished = False
        self.num_bytes = 0

    def __init__(out self, *coulmn_names: StringLiteral):
        self._capacity = 1024
        self._buffer = alloc[UInt8](self._capacity)
        self._elements_count = 0
        self._finished = False
        self.num_bytes = 0

        self._column_count = len(coulmn_names)
        for i in range(len(coulmn_names)):
            self.push(coulmn_names[i])

    def __del__(deinit self):
        if not self._finished:
            self._buffer.free()

    def push[D: DType](mut self, value: SIMD[D, 1]):
        var s = String.write(value)
        self.push(s, False)

    def push(mut self, value: Int):
        var s = String.write(value)
        self.push(s, False)

    def push_stringabel[T: Writable](mut self, value: T, consider_escaping: Bool = False):
        self.push(String.write(value), consider_escaping)

    def push_empty(mut self):
        self.push("", False)

    def fill_up_row(mut self):
        var num_empty = self._column_count - (
            self._elements_count % self._column_count
        )
        if num_empty < self._column_count:
            for _ in range(num_empty):
                self.push_empty()

    def push(mut self, s: String, consider_escaping: Bool = True):
        if consider_escaping and contains_any_of(
            s, CR_CHAR, LF_CHAR, COMMA_CHAR, QUOTE_CHAR
        ):
            return self.push(
                QUOTE_CHAR + escape_quotes_in(s) + QUOTE_CHAR, False
            )

        var size = len(s)
        self._extend_buffer_if_needed(size + 2)
        if self._elements_count > 0:
            if self._elements_count % self._column_count == 0:
                self._buffer.store(self.num_bytes, CR)
                self._buffer.store(self.num_bytes + 1, LF)
                self.num_bytes += 2
            else:
                self._buffer.store(self.num_bytes, COMMA)
                self.num_bytes += 1

        memcpy(dest=self._buffer + self.num_bytes, src=s.unsafe_ptr(), count=size)

        self.num_bytes += size
        self._elements_count += 1

    @always_inline
    def _extend_buffer_if_needed(mut self, size: Int):
        if self.num_bytes + size < self._capacity:
            return
        var new_size = self._capacity
        while new_size < self.num_bytes + size:
            new_size *= 2
        var p = alloc[UInt8](new_size)
        memcpy(dest=p, src=self._buffer, count=self.num_bytes)
        self._buffer.free()
        self._capacity = new_size
        self._buffer = p

    def finish(var self) -> String:
        self._finished = True
        self.fill_up_row()
        self._buffer.store(self.num_bytes, CR)
        self._buffer.store(self.num_bytes + 1, LF)
        self.num_bytes += 3
        return string_from_pointer(self._buffer, self.num_bytes)


def escape_quotes_in(s: String) -> String:
    s.find(QUOTE_CHAR)
    var indices = find_indices(s, QUOTE_CHAR)
    var i_size = len(indices)
    if i_size == 0:
        return s

    var size = s.byte_length()
    var p_current = s.unsafe_ptr()
    var p_result = alloc[UInt8](size + i_size)
    var first_index = Int(indices[0])
    memcpy(dest=p_result, src=p_current, count=first_index)
    p_result.store(first_index, QUOTE)
    var offset = first_index + 1
    for i in range(1, len(indices)):
        var c_offset = Int(indices[i - 1])
        var length = Int(indices[i]) - c_offset
        memcpy(dest=p_result + offset, src=p_current + c_offset, count=length)
        offset += length
        p_result.store(offset, QUOTE)
        offset += 1

    var last_index = Int(indices[i_size - 1])
    memcpy(
        dest=p_result + offset, src=p_current + last_index, count=size - last_index
    )
    return string_from_pointer(p_result, size + i_size)
