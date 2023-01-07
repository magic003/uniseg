module main

// This program generates properties and break test cases  in vlang files from the Unicode Character Database files.
//
// It accepts one argument of the following values:
//   - grapheme: grapheme properties
//   - grapheme_breaktest: grapheme break test cases
//   - word: word properties
//   - word_breaktest: word break test cases
//   - sentence: sentence properties
//   - sentence_breaktest: sentence break test cases
import gen.grapheme
import gen.word
import gen.sentence
import os

fn main() {
	if os.args.len < 2 {
		println('Not enough argument. Read code for more details.')
		exit(1)
	}

	file_type := os.args[1]
	match file_type {
		'grapheme' {
			grapheme.gen_grapheme_properties()
		}
		'grapheme_breaktest' {
			grapheme.gen_grapheme_breaktest()
		}
		'word' {
			word.gen_word_properties()
		}
		'word_breaktest' {
			word.gen_word_breaktest()
		}
		'sentence' {
			sentence.gen_sentence_properties()
		}
		'sentence_breaktest' {
			sentence.gen_sentence_breaktest()
		}
		else {
			println('Unrecognized argument: ${file_type}')
			exit(1)
		}
	}
}
