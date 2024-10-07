module sentence

import common
import net.http
import os

const sentence_breaktest_url = 'https://www.unicode.org/Public/${common.unicode_version}/ucd/auxiliary/SentenceBreakTest.txt'

// gen_sentence_breaktest generates a vlang file containing the sentence boundary break test cases.
pub fn gen_sentence_breaktest() {
	println('Fetching ${sentence_breaktest_url}...')
	lines := http.get_text(sentence_breaktest_url).split_into_lines()
	mut tests := [][]string{}
	for line in lines {
		if line.len == 0 || line.starts_with('#') {
			continue
		}
		str := line.all_before('#').trim_space()
		comment := line.all_after('#').trim_space()
		tests << [str, comment]
	}
	println('Finish parsing ${sentence_breaktest_url}.')

	write_sentence_breaktest(tests) or { panic(error) }
}

// write_sentence_breaktest writes the test cases to a sentence boundary break test vlang file.
fn write_sentence_breaktest(tests [][]string) ! {
	vfile_path := 'sentence/sentence_breaktest.v'
	println('Saving to file ${vfile_path}...')
	mut file := os.create(vfile_path)!
	defer {
		file.close()
		println('Finish saving file ${vfile_path}.')
	}
	file.writeln(common.emit_module('sentence') + '\n')!
	file.writeln(common.emit_preamble('gen/gen.v sentence_breaktest') + '\n')!
	file.writeln(common.emit_test_case_struct('SentenceBoundary') + '\n')!
	file.writeln('// sentence_break_test_cases are the sentence boundary break test cases.')!
	file.writeln('// They are taken from ${sentence_breaktest_url}.')!
	file.writeln('const sentence_break_test_cases = [')!
	for test in tests {
		input, expected := common.parse_input_and_expectation(test[0], 'SentenceBoundary',
			'sentence')
		file.writeln(common.emit_test_case(input, expected, test[1]))!
	}
	file.writeln(']')!
}
