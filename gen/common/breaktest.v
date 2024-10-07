module common

import strings

// emit_test_case_struct generates the vlang struct for a test case.
pub fn emit_test_case_struct(expected_struct string) string {
	return 'struct TestCase {\n' + 'input string @[required]\n' +
		'expected []${expected_struct} @[required]\n' + 'desc string\n' + '}'
}

// emit_test_case generates the vlang code for a single test case.
pub fn emit_test_case(input string, expected string, comment string) string {
	return "TestCase{ input: ${input}, expected: ${expected}, desc: '${comment}' }"
}

// parse_input_and_expectation constructs the input and expectation of a test case from the test string.
pub fn parse_input_and_expectation(test_str string, expected_struct string, expected_struct_text_field string) (string, string) {
	mut input_builder := strings.new_builder(2)
	input_builder.write_string("'")
	mut exp_builder := strings.new_builder(4)
	exp_builder.write_string('[ ')
	segments := test_str.trim_string_left('÷ ').trim_string_right(' ÷').split(' ÷ ')
	mut segment_start, mut segment_end := 0, 0
	for seg in segments {
		mut seg_builder := strings.new_builder(2)
		seg_builder.write_string("'")
		code_points := seg.split(' × ')
		for code_point in code_points {
			unicode := to_unicode(code_point)
			input_builder.write_string(unicode)
			seg_builder.write_string(unicode)
			segment_end += get_code_len_from_hex(code_point)
		}
		seg_builder.write_string("'")
		exp_builder.write_string('${expected_struct}{ ${expected_struct_text_field}: ${seg_builder.str()}, offset_start: ${segment_start}, offset_end: ${segment_end} }, ')
		segment_start = segment_end
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
