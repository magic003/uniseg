module word

import arrays
import io
import strings
import util

// from_string creates a `Words` instance from a string.
pub fn from_string(str string) Words {
	return Words{
		iter: util.rune_iter_from_string(str, true)
		state: State.st_sot
	}
}

// from_bytes creates a `Words` instance from a bytes array.
pub fn from_bytes(bytes []u8) Words {
	return Words{
		iter: util.rune_iter_from_bytes(bytes, true)
		state: State.st_sot
	}
}

// from_reader creates a `Words` instance from a `io.Reader`.
pub fn from_reader(reader io.Reader) Words {
	return Words{
		iter: util.rune_iter_from_reader(reader, true)
		state: State.st_sot
	}
}

// WordBoundary represents a word boundary.
pub struct WordBoundary {
pub:
	offset_start int    [required] // offset of the first byte in word
	offset_end   int    [required] // offset of the first byte doesn't belong to the word
	word         string [required]
}

// Word breaks a string into Unicode words. It implements the iteration interface.
//
// The instance can be constructed using `from_string()`, `from_bytes()` or `from_reader()`. The `next()` method
// can be called to get the next word boundary.
[noinit]
pub struct Words {
mut:
	iter         util.RuneIter   [required]
	state        State           [required]
	builder      strings.Builder = strings.new_builder(1) // keep the runes seen so far
	offset_start int // offset of the first byte of the builder
	offset_end   int // offset which doesn't include the last byte of the builder
}

// next implements the iteration interface, returning the next word boundary.
pub fn (mut self Words) next() ?WordBoundary {
	if self.state == State.st_eot {
		return none
	}

	for {
		next_state, is_boundary, runes := check_boundary(self.state, mut self.iter)
		defer {
			self.state = next_state
		}
		if next_state == State.st_eot {
			if self.state == State.st_sot {
				return none
			}
			return WordBoundary{self.offset_start, self.offset_end, self.builder.str()}
		}
		total_bytes_count := arrays.sum(runes.map(fn (r rune) int {
			return r.bytes().len
		})) or { 0 }
		if is_boundary {
			last_rune := runes.last()
			// put extra runes into the builder, if there is any.
			self.offset_end += (total_bytes_count - last_rune.bytes().len)
			self.builder.write_runes(runes#[0..-1])
			res := WordBoundary{self.offset_start, self.offset_end, self.builder.str()}

			// add the last rune
			self.builder.write_rune(last_rune)
			self.offset_start = self.offset_end
			self.offset_end = self.offset_end + last_rune.bytes().len
			return res
		}
		self.builder.write_runes(runes)
		self.offset_end += total_bytes_count
	}

	// should never reach here
	return none
}
