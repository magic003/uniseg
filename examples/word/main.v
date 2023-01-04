module main

import magic003.uniseg.word

fn main() {
	mut words := word.from_string('Hello, world!')
	for w in words {
		println('${w.word}\t[${w.offset_start}, ${w.offset_end}]')
	}
	// Output:
	// Hello   [0, 5]
	// ,       [5, 6]
	//         [6, 7]
	// world   [7, 12]
	// !       [12, 13]
}
