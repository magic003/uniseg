module grapheme

import common
import os

const (
	grapheme_property_url = 'https://www.unicode.org/Public/${common.unicode_version}/ucd/auxiliary/GraphemeBreakProperty.txt'
	emoji_property_url    = 'https://unicode.org/Public/${common.unicode_version}/ucd/emoji/emoji-data.txt'
)

// gen_grapheme_properties fetches properties and generates a vlang file used by grapheme cluster boundary rules.
pub fn gen_grapheme_properties() {
	mut properties := []common.Property{}

	properties << common.parse_properties(grapheme.grapheme_property_url, fn (line string) bool {
		return true
	})

	properties << common.parse_properties(grapheme.emoji_property_url, fn (line string) bool {
		return line.contains('Extended_Pictographic')
	})

	properties.sort_with_compare(fn (a &common.Property, b &common.Property) int {
		return '0x${a.from}'.int() - '0x${b.from}'.int()
	})

	write_grapheme_properties(properties) or { panic(error) }
}

// write_grapheme_properties writes the properties to a grapheme properties vlang file.
fn write_grapheme_properties(properties []common.Property) ! {
	vfile_path := 'grapheme/grapheme_properties.v'
	println('Saving to file ${vfile_path}...')
	mut file := os.create(vfile_path)!
	defer {
		file.close()
		println('Finish saving file ${vfile_path}.')
	}
	file.writeln(common.emit_module('grapheme') + '\n')!
	file.writeln(common.emit_preamble('gen/gen.v grapheme') + '\n')!
	file.writeln('// GraphemeProp defines the property types used for grapheme cluster boundary detection.')!
	file.writeln(
		common.emit_property_enum('GraphemeProp', common.unique_property_names(properties), 'gp') +
		'\n')!
	file.writeln('// GraphemeCodePoint defines the code point range for a property.')!
	file.writeln(common.emit_code_points_struct('GraphemeCodePoint', 'GraphemeProp') + '\n')!
	file.writeln('// grapheme_properties are the properties used for grapheme cluster boundary detection.')!
	file.writeln('// They are taken from ${grapheme.grapheme_property_url}\n// and\n// ${grapheme.emoji_property_url}\n// ("Extended_Pictographic" only).')!
	file.writeln(
		common.emit_property_array('grapheme_properties', properties, 'GraphemeCodePoint', 'GraphemeProp', 'gp') +
		'\n')!
}
