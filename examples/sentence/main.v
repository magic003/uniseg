module main

import magic003.uniseg.sentence

fn main() {
	mut sentences := sentence.from_string('This is sentence 1.0. And this is sentence two.')
	for s in sentences {
		println('(${s.sentence}) [${s.offset_start}, ${s.offset_end}]')
	}
	// Output:
	// (This is sentence 1.0. ) [0, 22]
	// (And this is sentence two.) [22, 47]
}
