module grapheme

// basic_test_cases have the basic test cases. Copied from https://github.com/rivo/uniseg/blob/master/grapheme_test.go.
const basic_test_cases = [
	TestCase{
		input: ''
		expected: []
	},
	TestCase{
		input: 'x'
		expected: [
			GraphemeCluster{
				offset_start: 0
				offset_end: 1
				cluster: 'x'
			},
		]
	},
	TestCase{
		input: 'basic'
		expected: [
			GraphemeCluster{
				offset_start: 0
				offset_end: 1
				cluster: 'b'
			},
			GraphemeCluster{
				offset_start: 1
				offset_end: 2
				cluster: 'a'
			},
			GraphemeCluster{
				offset_start: 2
				offset_end: 3
				cluster: 's'
			},
			GraphemeCluster{
				offset_start: 3
				offset_end: 4
				cluster: 'i'
			},
			GraphemeCluster{
				offset_start: 4
				offset_end: 5
				cluster: 'c'
			},
		]
	},
	TestCase{
		input: 'möp'
		expected: [
			GraphemeCluster{
				offset_start: 0
				offset_end: 1
				cluster: 'm'
			},
			GraphemeCluster{
				offset_start: 1
				offset_end: 3
				cluster: 'ö'
			},
			GraphemeCluster{
				offset_start: 3
				offset_end: 4
				cluster: 'p'
			},
		]
	},
	TestCase{
		input: '\r\n'
		expected: [
			GraphemeCluster{
				offset_start: 0
				offset_end: 2
				cluster: '\r\n'
			},
		]
	},
	TestCase{
		input: '\n\n'
		expected: [
			GraphemeCluster{
				offset_start: 0
				offset_end: 1
				cluster: '\n'
			},
			GraphemeCluster{
				offset_start: 1
				offset_end: 2
				cluster: '\n'
			},
		]
	},
	TestCase{
		input: '\t*'
		expected: [
			GraphemeCluster{
				offset_start: 0
				offset_end: 1
				cluster: '\t'
			},
			GraphemeCluster{
				offset_start: 1
				offset_end: 2
				cluster: '*'
			},
		]
	},
	TestCase{
		input: '뢴'
		expected: [
			GraphemeCluster{
				offset_start: 0
				offset_end: 3
				cluster: '뢴'
			},
		]
	},
	TestCase{
		input: 'ܐ܏ܒܓܕ'
		expected: [
			GraphemeCluster{
				offset_start: 0
				offset_end: 2
				cluster: 'ܐ'
			},
			GraphemeCluster{
				offset_start: 2
				offset_end: 6
				cluster: '܏ܒ'
			},
			GraphemeCluster{
				offset_start: 6
				offset_end: 8
				cluster: 'ܓ'
			},
			GraphemeCluster{
				offset_start: 8
				offset_end: 10
				cluster: 'ܕ'
			},
		]
	},
	TestCase{
		input: 'ำ'
		expected: [
			GraphemeCluster{
				offset_start: 0
				offset_end: 3
				cluster: 'ำ'
			},
		]
	},
	TestCase{
		input: 'ำำ'
		expected: [
			GraphemeCluster{
				offset_start: 0
				offset_end: 6
				cluster: 'ำำ'
			},
		]
	},
	TestCase{
		input: 'สระอำ'
		expected: [
			GraphemeCluster{
				offset_start: 0
				offset_end: 3
				cluster: 'ส'
			},
			GraphemeCluster{
				offset_start: 3
				offset_end: 6
				cluster: 'ร'
			},
			GraphemeCluster{
				offset_start: 6
				offset_end: 9
				cluster: 'ะ'
			},
			GraphemeCluster{
				offset_start: 9
				offset_end: 15
				cluster: 'อำ'
			},
		]
	},
	TestCase{
		input: '*뢴*'
		expected: [
			GraphemeCluster{
				offset_start: 0
				offset_end: 1
				cluster: '*'
			},
			GraphemeCluster{
				offset_start: 1
				offset_end: 4
				cluster: '뢴'
			},
			GraphemeCluster{
				offset_start: 4
				offset_end: 5
				cluster: '*'
			},
		]
	},
	TestCase{
		input: '*👩‍❤️‍💋‍👩*'
		expected: [
			GraphemeCluster{
				offset_start: 0
				offset_end: 1
				cluster: '*'
			},
			GraphemeCluster{
				offset_start: 1
				offset_end: 28
				cluster: '👩‍❤️‍💋‍👩'
			},
			GraphemeCluster{
				offset_start: 28
				offset_end: 29
				cluster: '*'
			},
		]
	},
	TestCase{
		input: '👩‍❤️‍💋‍👩'
		expected: [
			GraphemeCluster{
				offset_start: 0
				offset_end: 27
				cluster: '👩‍❤️‍💋‍👩'
			},
		]
	},
	TestCase{
		input: '🏋🏽‍♀️'
		expected: [
			GraphemeCluster{
				offset_start: 0
				offset_end: 17
				cluster: '🏋🏽‍♀️'
			},
		]
	},
	TestCase{
		input: '🙂'
		expected: [
			GraphemeCluster{
				offset_start: 0
				offset_end: 4
				cluster: '🙂'
			},
		]
	},
	TestCase{
		input: '🙂🙂'
		expected: [
			GraphemeCluster{
				offset_start: 0
				offset_end: 4
				cluster: '🙂'
			},
			GraphemeCluster{
				offset_start: 4
				offset_end: 8
				cluster: '🙂'
			},
		]
	},
	TestCase{
		input: '🇩🇪'
		expected: [
			GraphemeCluster{
				offset_start: 0
				offset_end: 8
				cluster: '🇩🇪'
			},
		]
	},
	TestCase{
		input: '🏳️‍🌈'
		expected: [
			GraphemeCluster{
				offset_start: 0
				offset_end: 14
				cluster: '🏳️‍🌈'
			},
		]
	},
	TestCase{
		input: '\t🏳️‍🌈'
		expected: [
			GraphemeCluster{
				offset_start: 0
				offset_end: 1
				cluster: '\t'
			},
			GraphemeCluster{
				offset_start: 1
				offset_end: 15
				cluster: '🏳️‍🌈'
			},
		]
	},
	TestCase{
		input: '\t🏳️‍🌈\t'
		expected: [
			GraphemeCluster{
				offset_start: 0
				offset_end: 1
				cluster: '\t'
			},
			GraphemeCluster{
				offset_start: 1
				offset_end: 15
				cluster: '🏳️‍🌈'
			},
			GraphemeCluster{
				offset_start: 15
				offset_end: 16
				cluster: '\t'
			},
		]
	},
]

// run_graphemes iterates over the `Graphemes` and collects the results.
fn run_graphemes(input string) []GraphemeCluster {
	mut gs := from_string(input)
	mut res := []GraphemeCluster{}
	for gc in gs {
		res << gc
	}
	return res
}

fn test_graphemes_basic_cases() {
	for test in grapheme.basic_test_cases {
		assert test.expected == run_graphemes(test.input)
	}
}

fn test_graphemes_breaktest() {
	for test in grapheme_break_test_cases {
		assert test.expected == run_graphemes(test.input), test.desc
	}
}
