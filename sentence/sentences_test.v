module sentence

// run_sentences iterates over the `Sentences` and collects the results.
fn run_sentences(input string) []SentenceBoundary {
	mut sentences := from_string(input)
	mut res := []SentenceBoundary{}
	for s in sentences {
		res << s
	}
	return res
}

fn test_sentences_breaktest() {
	for test in sentence_break_test_cases {
		assert test.expected == run_sentences(test.input), test.desc
	}
}
