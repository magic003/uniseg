module main

import os
import net.http
import regex

fn main() {
	if os.args.len < 2 {
		println('Not enough argument. Read code for more details.')
		exit(1)
	}

	segmentation_type := os.args[1]
	match segmentation_type {
		'grapheme' {
			gen_grapheme_properties()
		}
		else {
			println('Unrecognized argument: ${segmentation_type}')
			exit(1)
		}
	}
}

// unicode_version is the Unicode version that this unicode-segmentation lib is based on.
const unicode_version = '15.0.0'

const (
	grapheme_property_url = 'https://www.unicode.org/Public/${unicode_version}/ucd/auxiliary/GraphemeBreakProperty.txt'
	emoji_property_url    = 'https://unicode.org/Public/${unicode_version}/ucd/emoji/emoji-data.txt'
)

// property_line_regex is the regexp matching a property line.
const property_line_regex = r'^(?P<start>[0-9A-F]{4,6})(\.\.(?P<to>[0-9A-F]{4,6}))?\s*;\s*(?P<property>[A-Za-z0-9_]+)\s*#\s(?P<comment>.+)$'

fn gen_grapheme_properties() {
	mut properties := []Property{}

	properties << parse_properties(grapheme_property_url, fn (line string) bool {
		return true
	})

	properties << parse_properties(emoji_property_url, fn (line string) bool {
		return line.contains('Extended_Pictographic')
	})

	println(properties)
}

// Property represents a property. It is a line in the fetched properties file.
struct Property {
	from     string
	to       string
	property string
	comment  string
}

fn parse_properties(url string, filter fn (string) bool) []Property {
	mut properties := []Property{}

	println('Fetching ${url}...')
	lines := http.get_text(emoji_property_url).split_into_lines()
	for line in lines {
		if line.len == 0 || line.starts_with('#') || !filter(line) {
			continue
		}
		prop := parse_line(line) or { continue }
		properties << prop
	}
	println('Finish parsing ${url}.')

	return properties
}

fn parse_line(line string) ?Property {
	mut re := regex.regex_opt(property_line_regex) or { panic(error) }
	match_start, _ := re.match_string(line)
	if match_start < 0 {
		return none
	}

	start := re.get_group_by_name(line, 'start')
	to := if re.get_group_by_name(line, 'to') == '' {
		start
	} else {
		re.get_group_by_name(line, 'to')
	}
	property := re.get_group_by_name(line, 'property')
	comment := re.get_group_by_name(line, 'comment')

	return Property{start, to, property, comment}
}
