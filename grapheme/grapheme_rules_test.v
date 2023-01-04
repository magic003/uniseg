module grapheme

fn test_get_grapheme_property() {
	// first element
	assert GraphemeProp.gp_control == get_grapheme_property(`\u0008`)
	// some element in the middle
	assert GraphemeProp.gp_extended_pictographic == get_grapheme_property(`🤧`) // \u1f927
	// element close to the end
	assert GraphemeProp.gp_extended_pictographic == get_grapheme_property(`🫶`) // \u1FAF6
	// any element not in the array
	assert GraphemeProp.gp_any == get_grapheme_property(`\u0200`)
}
