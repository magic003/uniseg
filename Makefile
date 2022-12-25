gen-grapheme:
	v run gen/. grapheme
	v fmt -w src/grapheme/grapheme_properties.v

test:
	v -stats test src/.
