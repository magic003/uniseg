module word

import common
import os

const word_property_url = 'https://www.unicode.org/Public/${common.unicode_version}/ucd/auxiliary/WordBreakProperty.txt'
const emoji_property_url = 'https://unicode.org/Public/${common.unicode_version}/ucd/emoji/emoji-data.txt'

// gen_word_properties fetches properties and generates a vlang file used by word boundary rules.
pub fn gen_word_properties() {
	mut properties := []common.Property{}

	properties << common.parse_properties(word_property_url, fn (line string) bool {
		return true
	})

	properties << common.parse_properties(emoji_property_url, fn (line string) bool {
		return line.contains('Extended_Pictographic')
	})

	properties.sort_with_compare(fn (a &common.Property, b &common.Property) int {
		return '0x${a.from}'.int() - '0x${b.from}'.int()
	})

	write_word_properties(properties) or { panic(error) }
}

// write_word_properties writes the properties to a word properties vlang file.
fn write_word_properties(properties []common.Property) ! {
	vfile_path := 'word/word_properties.v'
	println('Saving to file ${vfile_path}...')
	mut file := os.create(vfile_path)!
	defer {
		file.close()
		println('Finish saving file ${vfile_path}.')
	}
	file.writeln(common.emit_module('word') + '\n')!
	file.writeln(common.emit_preamble('gen/gen.v word') + '\n')!
	file.writeln('// WordProp defines the property types used for word boundary detection.')!
	file.writeln(
		common.emit_property_enum('WordProp', common.unique_property_names(properties), 'wp') + '\n')!
	file.writeln('// WordCodePoint defines the code point range for a property.')!
	file.writeln(common.emit_code_points_struct('WordCodePoint', 'WordProp') + '\n')!
	file.writeln('// word_properties are the properties used for word boundary detection.')!
	file.writeln('// They are taken from ${word_property_url}\n// and\n// ${emoji_property_url}\n// ("Extended_Pictographic" only).')!
	file.writeln(
		common.emit_property_array('word_properties', properties, 'WordCodePoint', 'WordProp', 'wp') +
		'\n')!
}
