module main

import os

fn main() {
	if os.args.len < 1 {
		println('Expect at least one argument. Read code for more details.')
		exit(1)
	}

	match os.args[0] {
		'grapheme' {
			gen_grapheme_properties()
		}
		else {
			println('Unrecognized argument: ${os.args[0]}')
			exit(1)
		}
	}
}

// unicode_version is the Unicode version that this unicode-segmentation lib is based on.
const unicode_version = '15.0.0'

fn gen_grapheme_properties() {
}
