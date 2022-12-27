module main

// This program generates a vlang file with the break test cases from the Unicode Character Database files.
//
// It accepts one argument of the following values:
//   - grapheme
import os

fn main() {
	if os.args.len < 2 {
		println('Not enough argument. Read code for more details.')
		exit(1)
	}

	segmentation_type := os.args[1]
	match segmentation_type {
		'grapheme' {
			gen_grapheme_breaktest()
		}
		else {
			println('Unrecognized argument: ${segmentation_type}')
			exit(1)
		}
	}
}
