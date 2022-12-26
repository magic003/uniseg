module grapheme

import io
import strings
import util

// from_string creates a `Graphemes` instance from a string.
pub fn from_string(str string) Graphemes {
	return Graphemes{
		iter: util.rune_iter_from_string(str)
		state: State.st_sot
	}
}

// from_bytes creates a `Graphemes` instance from a bytes array.
pub fn from_bytes(bytes []u8) Graphemes {
	return Graphemes{
		iter: util.rune_iter_from_bytes(bytes)
		state: State.st_sot
	}
}

// from_reader creates a `Graphemes` instance from a `io.Reader`.
pub fn from_reader(reader io.Reader) Graphemes {
	return Graphemes{
		iter: util.rune_iter_from_reader(reader)
		state: State.st_sot
	}
}

// GraphemeCluster represents a grapheme cluster.
pub struct GraphemeCluster {
pub:
	offset_start int    [required] // offset of the first byte in cluster
	offset_end   int    [required] // offset of the first byte doesn't belong to the cluster
	cluster      string [required]
}

// Graphemes breaks a string into Unicode grapheme clusters, or user-perceived characters. It implements the
// iteration interface.
//
// The instance can be constructed using `from_string()`, `from_bytes()` or `from_reader()`. The `next()` method
// can be called to get the next grapheme cluster.
[noinit]
pub struct Graphemes {
mut:
	iter         util.RuneIter   [required]
	state        State           [required]
	builder      strings.Builder = strings.new_builder(1) // keep the rune seen so far
	offset_start int = 0 // offset of the first byte of the builder
	offset_end   int = 0 // offset which doesn't include the last byte of the builder
}

// next implements the iteration interface, returning the next grapheme cluster.
pub fn (mut self Graphemes) next() ?GraphemeCluster {
	if self.state == State.st_eot {
		return none
	}

	for {
		r, start, end := self.iter.next() or {
			self.state = State.st_eot
			return GraphemeCluster{self.offset_start, self.offset_end, self.builder.str()}
		}
		next_state, is_boundary := check_boundary(self.state, r)
		self.state = next_state
		if is_boundary {
			res := GraphemeCluster{self.offset_start, self.offset_end, self.builder.str()}
			self.builder.write_rune(r)
			self.offset_start = start
			self.offset_end = end
			return res
		}
		self.builder.write_rune(r)
		self.offset_end = end
	}

	// should never reach here
	return none
}
