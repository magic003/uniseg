module word

// run_words iterates over the `Words` and collects the results.
fn run_words(input string) []WordBoundary {
	mut words := from_string(input)
	mut res := []WordBoundary{}
	for w in words {
		res << w
	}
	return res
}

fn test_words_breaktest() {
	for test in word_break_test_cases {
		assert test.expected == run_words(test.input), test.desc
	}
}
