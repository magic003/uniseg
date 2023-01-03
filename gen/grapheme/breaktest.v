module grapheme

import common
import net.http
import os

const (
	grapheme_breaktest_url = 'https://www.unicode.org/Public/${common.unicode_version}/ucd/auxiliary/GraphemeBreakTest.txt'
)

// gen_grapheme_breaktest generates a vlang file containing the grapheme cluster break test cases.
pub fn gen_grapheme_breaktest() {
	println('Fetching ${grapheme.grapheme_breaktest_url}...')
	lines := http.get_text(grapheme.grapheme_breaktest_url).split_into_lines()
	mut tests := [][]string{}
	for line in lines {
		if line.len == 0 || line.starts_with('#') {
			continue
		}
		str := line.all_before('#').trim_space()
		comment := line.all_after('#').trim_space()
		tests << [str, comment]
	}
	println('Finish parsing ${grapheme.grapheme_breaktest_url}.')

	write_grapheme_breaktest(tests) or { panic(error) }
}

// write_grapheme_breaktest writes the test cases to a grapheme break test vlang file.
fn write_grapheme_breaktest(tests [][]string) ! {
	vfile_path := 'src/grapheme/grapheme_breaktest.v'
	println('Saving to file ${vfile_path}...')
	mut file := os.create(vfile_path)!
	defer {
		file.close()
		println('Finish saving file ${vfile_path}.')
	}
	file.writeln(common.emit_module('grapheme') + '\n')!
	file.writeln(common.emit_preamble('gen/gen.v grapheme_breaktest') + '\n')!
	file.writeln(common.emit_test_case_struct('GraphemeCluster') + '\n')!
	file.writeln('// grapheme_break_test_cases are the grapheme cluster break test cases.')!
	file.writeln('// They are taken from ${grapheme.grapheme_breaktest_url}.')!
	file.writeln('const grapheme_break_test_cases = [')!
	for test in tests {
		input, expected := common.parse_input_and_expectation(test[0], 'GraphemeCluster',
			'cluster')
		file.writeln(common.emit_test_case(input, expected, test[1]))!
	}
	file.writeln(']')!
}
