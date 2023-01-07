module sentence

fn test_get_sentence_property() {
	// first element
	assert SentenceProp.sp_sp == get_sentence_property(`\u0009`)
	// some element in the middle
	assert SentenceProp.sp_oletter == get_sentence_property(`\u0D0C`)
	// element at the end
	assert SentenceProp.sp_extend == get_sentence_property('\U000E01EF'.runes()[0])
	// any element not in the array
	assert SentenceProp.sp_any == get_sentence_property(`\u0001`)
}
