module main

import magic003.uniseg.grapheme

fn main() {
	mut graphemes := grapheme.from_string('🇩🇪🏳️‍🌈!')
	for g in graphemes {
		println('${g.cluster}   [${g.offset_start}, ${g.offset_end}]')
	}
	// Output:
	// 🇩🇪   [0, 8]
	//🏳️‍🌈   [8, 22]
	// !   [22, 23]
}
