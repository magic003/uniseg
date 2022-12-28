module grapheme

import common
import net.http
import os
import strings

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
	file.writeln(emit_test_case_struct() + '\n')!
	file.writeln('// grapheme_break_test_cases are the grapheme cluster break test cases.')!
	file.writeln('// They are taken from ${grapheme.grapheme_breaktest_url}.')!
	file.writeln('const grapheme_break_test_cases = [')!
	for test in tests {
		input, expected := parse_input_and_expectation(test[0])
		file.writeln(emit_test_case(input, expected, test[1]))!
	}
	file.writeln(']')!
}

fn emit_test_case_struct() string {
	return 'struct TestCase {\n' + 'input string [required]\n' +
		'expected []GraphemeCluster [required]\n' + '}'
}

// emit_test_case generates the vlang code for a single test case.
fn emit_test_case(input string, expected string, comment string) string {
	return '// ${comment}\nTestCase{ input: ${input}, expected: ${expected} }'
}

// parse_input_and_expectation constructs the input and expectation of a test case from the test string.
fn parse_input_and_expectation(test_str string) (string, string) {
	mut input_builder := strings.new_builder(2)
	input_builder.write_string("'")
	mut exp_builder := strings.new_builder(4)
	exp_builder.write_string('[ ')
	clusters := test_str.trim_string_left('÷ ').trim_string_right(' ÷').split(' ÷ ')
	mut cluster_start, mut cluster_end := 0, 0
	for cluster in clusters {
		mut cluster_builder := strings.new_builder(2)
		cluster_builder.write_string("'")
		code_points := cluster.split(' × ')
		for code_point in code_points {
			unicode := to_unicode(code_point)
			input_builder.write_string(unicode)
			cluster_builder.write_string(unicode)
			cluster_end += get_code_len_from_hex(code_point)
		}
		cluster_builder.write_string("'")
		exp_builder.write_string('GraphemeCluster{ cluster: ${cluster_builder.str()}, offset_start: ${cluster_start}, offset_end: ${cluster_end} }, ')
		cluster_start = cluster_end
	}

	input_builder.write_string("'")
	exp_builder.write_string(' ]')
	return input_builder.str(), exp_builder.str()
}

// get_code_len_from_hex returns the bytes count of the code point represented by the hex string.
fn get_code_len_from_hex(hex string) int {
	return utf32_to_str('0x${hex}'.u32()).bytes().len
}

// to_unicode returns the Unicode representation of the hex string.
fn to_unicode(hex string) string {
	return if hex.len == 4 { '\\u${hex}' } else { '\\U000${hex}' }
}
