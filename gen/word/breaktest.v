module word

import common
import net.http
import os

const (
	word_breaktest_url = 'https://www.unicode.org/Public/${common.unicode_version}/ucd/auxiliary/WordBreakTest.txt'
)

// gen_word_breaktest generates a vlang file containing the word boundary break test cases.
pub fn gen_word_breaktest() {
	println('Fetching ${word.word_breaktest_url}...')
	lines := http.get_text(word.word_breaktest_url).split_into_lines()
	mut tests := [][]string{}
	for line in lines {
		if line.len == 0 || line.starts_with('#') {
			continue
		}
		str := line.all_before('#').trim_space()
		comment := line.all_after('#').trim_space()
		tests << [str, comment]
	}
	println('Finish parsing ${word.word_breaktest_url}.')

	write_word_breaktest(tests) or { panic(error) }
}

// write_word_breaktest writes the test cases to a word boundary break test vlang file.
fn write_word_breaktest(tests [][]string) ! {
	vfile_path := 'src/word/word_breaktest.v'
	println('Saving to file ${vfile_path}...')
	mut file := os.create(vfile_path)!
	defer {
		file.close()
		println('Finish saving file ${vfile_path}.')
	}
	file.writeln(common.emit_module('word') + '\n')!
	file.writeln(common.emit_preamble('gen/gen.v word_breaktest') + '\n')!
	file.writeln(common.emit_test_case_struct('WordBoundary') + '\n')!
	file.writeln('// word_break_test_cases are the word boundary break test cases.')!
	file.writeln('// They are taken from ${word.word_breaktest_url}.')!
	file.writeln('const word_break_test_cases = [')!
	for test in tests {
		input, expected := common.parse_input_and_expectation(test[0], 'WordBoundary',
			'word')
		file.writeln(common.emit_test_case(input, expected, test[1]))!
	}
	file.writeln(']')!
}
