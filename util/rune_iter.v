module util

import arrays
import math
import io

// RuneIter is an interface which iterates over `rune`s. It abstracts the source of the `rune`s and provides
// a stream-like interface to get `rune` one by one.
//
// The next() method returns the next rune with its byte offsets from the source. The end offset is exclusive.
// The intention is to implement the iteration interface so it can be used in V's `for/in` loop. However, it turns
// out an interface doesn't work.
//
// The rewind() method moves the iterator n runes back. An error can be returned if something unexpected happens.
pub interface RuneIter {
mut:
	next() ?(rune, int, int)
	rewind(int) !
}

// rune_iter_from_string returns a `RuneIter` from a `string`.
pub fn rune_iter_from_string(str string, rewindable bool) RuneIter {
	return BytesRuneIter{
		bytes: str.bytes()
		rewindable: rewindable
	}
}

// rune_iter_from_bytes returns a `RuneIter` from a byte array.
pub fn rune_iter_from_bytes(bytes []u8, rewindable bool) RuneIter {
	return BytesRuneIter{
		bytes: bytes
		rewindable: rewindable
	}
}

// rune_iter_from_reader returns a `RuneIter` from a reader.
pub fn rune_iter_from_reader(reader io.Reader, rewindable bool) RuneIter {
	return ReaderRuneIter{
		reader: reader
		rewindable: rewindable
	}
}

// BytesRuneIter is a `RuneIter` backed by an array of bytes.
@[noinit]
struct BytesRuneIter {
	bytes      []u8 @[required]
	rewindable bool
mut:
	current_index int
	rune_lens     []int
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
	r := ch_bytes.byterune() or { return none }
	self.current_index = end

	if self.rewindable {
		self.rune_lens << ch_len
	}

	return r, start, end
}

// rewind implements the `RuneIter` interface.
fn (mut self BytesRuneIter) rewind(count int) ! {
	if !self.rewindable {
		return error('rewind is not supported')
	}
	if count < 0 {
		return error('the rewind rune count should not be negative')
	}
	if count == 0 {
		return
	}

	n := math.min(count, self.rune_lens.len)
	bytes_to_rewind := arrays.sum(self.rune_lens#[-n..]) or { 0 }
	self.current_index -= bytes_to_rewind
	self.rune_lens.trim(self.rune_lens.len - n)
}

// ReaderRuneIter is a `RuneIter` backed by a `io.Reader`.
@[noinit]
struct ReaderRuneIter {
	rewindable bool
mut:
	reader        io.Reader @[required]
	current_index int
	cached_runes  []rune
	cached_index  int
}

// next implements the `RuneIter` interface.
fn (mut self ReaderRuneIter) next() ?(rune, int, int) {
	// use cached runes if the index is not at the end. It means a rewind happened previously.
	if self.cached_index < self.cached_runes.len {
		r := self.cached_runes[self.cached_index]
		start, end := self.current_index, self.current_index + r.bytes().len
		self.current_index = end
		self.cached_index++
		return r, start, end
	}

	mut buf := []u8{len: 1}
	self.reader.read(mut buf) or { return none }

	ch_len := utf8_char_len(buf[0])
	start := self.current_index
	end := self.current_index + ch_len
	mut ch_bytes := [buf[0]]
	for _ in (start + 1) .. end {
		self.reader.read(mut buf) or { return none }
		ch_bytes << buf[0]
	}
	r := ch_bytes.byterune() or { return none }
	self.current_index = end

	if self.rewindable {
		self.cached_runes << r
		self.cached_index++
	}

	return r, start, end
}

fn (mut self ReaderRuneIter) rewind(count int) ! {
	if !self.rewindable {
		return error('rewind is not supported')
	}
	if count < 0 {
		return error('the rewind rune count should not be negative')
	}
	if count == 0 {
		return
	}

	n := math.min(count, self.cached_runes.len)
	bytes_to_rewind := arrays.sum(self.cached_runes#[-n..].map(fn (r rune) int {
		return r.bytes().len
	})) or { 0 }
	self.current_index -= bytes_to_rewind
	self.cached_index -= n
}
