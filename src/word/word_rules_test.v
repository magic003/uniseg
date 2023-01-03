module word

fn test_get_word_property() {
	// first element
	assert WordProp.wp_lf == get_word_property(`\u000A`)
	// some element in the middle
	assert WordProp.wp_extended_pictographic == get_word_property(`🤧`) // \u1f927
	// element close to the end
	assert WordProp.wp_extended_pictographic == get_word_property(`🫶`) // \u1FAF6
	// any element not in the array
	assert WordProp.wp_any == get_word_property(`\u0001`)
}
