module util

// RuneIter is an interface which iterates over `rune`s. It abstracts the source of the `rune`s and provides
// a stream-like interface to get `rune` one by one.
//
// The next() method returns the next rune with its byte offsets from the source. The end offset is exclusive.
// The intention is to implement the iteration interface so it can be used in V's `for/in` loop. However, it turns
// out an interface doesn't work.
pub interface RuneIter {
mut:
	next() ?(rune, int, int)
}

// rune_iter_from_string returns a `RuneIter` from a `string`.
pub fn rune_iter_from_string(str string) RuneIter {
	return BytesRuneIter{
		bytes: str.bytes()
	}
}

// rune_iter_from_bytes returns a `RuneIter` from a byte array.
pub fn rune_iter_from_bytes(bytes []u8) RuneIter {
	return BytesRuneIter{
		bytes: bytes
	}
}

// BytesRuneIter is a `RuneIter` backed by an array of bytes.
[noinit]
struct BytesRuneIter {
	bytes []u8 [required]
mut:
	current_index int
}

// next impelements the `RuneIter` interface.
fn (mut self BytesRuneIter) next() ?(rune, int, int) {
	if self.current_index >= self.bytes.len {
		return none
	}
	ch_len := utf8_char_len(self.bytes[self.current_index])
	mut ch_bytes := []u8{}
	start := self.current_index
	end := self.current_index + ch_len
	for i in start .. end {
		ch_bytes << self.bytes[i]
	}
	r := ch_bytes.byterune()?
	self.current_index = end

	return r, start, end
}
