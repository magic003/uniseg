module grapheme

// run_graphemes iterates over the `Graphemes` and collects the results.
fn run_graphemes(input string) []GraphemeCluster {
	mut gs := from_string(input)
	mut res := []GraphemeCluster{}
	for gc in gs {
		res << gc
	}
	return res
}

fn test_graphemes_breaktest() {
	for test in grapheme_break_test_cases {
		assert test.expected == run_graphemes(test.input)
	}
}
