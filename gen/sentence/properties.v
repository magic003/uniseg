module sentence

import common
import os

const sentence_property_url = 'https://www.unicode.org/Public/${common.unicode_version}/ucd/auxiliary/SentenceBreakProperty.txt'

// gen_sentence_properties fetches properties and generates a vlang file used by sentence boundary rules.
pub fn gen_sentence_properties() {
	mut properties := []common.Property{}

	properties << common.parse_properties(sentence_property_url, fn (line string) bool {
		return true
	})

	properties.sort_with_compare(fn (a &common.Property, b &common.Property) int {
		return '0x${a.from}'.int() - '0x${b.from}'.int()
	})

	write_sentence_properties(properties) or { panic(error) }
}

// write_sentence_properties writes the properties to a sentence properties vlang file.
fn write_sentence_properties(properties []common.Property) ! {
	vfile_path := 'sentence/sentence_properties.v'
	println('Saving to file ${vfile_path}...')
	mut file := os.create(vfile_path)!
	defer {
		file.close()
		println('Finish saving file ${vfile_path}.')
	}
	file.writeln(common.emit_module('sentence') + '\n')!
	file.writeln(common.emit_preamble('gen/gen.v sentence') + '\n')!
	file.writeln('// SentenceProp defines the property types used for sentence boundary detection.')!
	file.writeln(
		common.emit_property_enum('SentenceProp', common.unique_property_names(properties), 'sp') +
		'\n')!
	file.writeln('// SentenceCodePoint defines the code point range for a property.')!
	file.writeln(common.emit_code_points_struct('SentenceCodePoint', 'SentenceProp') + '\n')!
	file.writeln('// sentence_properties are the properties used for sentence boundary detection.')!
	file.writeln('// They are taken from ${sentence_property_url}.\n')!
	file.writeln(
		common.emit_property_array('sentence_properties', properties, 'SentenceCodePoint', 'SentenceProp', 'sp') +
		'\n')!
}
