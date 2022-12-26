module grapheme

// GraphemeCluster represents a grapheme cluster.
pub struct GraphemeCluster {
pub:
	offset_start u32    [required]
	offset_end   u32    [required]
	cluster      string [required]
}

[noinit]
pub struct Graphemes {
}

pub fn (mut self Graphemes) next() ?GraphemeCluster {
	return none
}
