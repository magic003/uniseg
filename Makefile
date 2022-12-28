gen-grapheme:
	v gen/.
	./gen/gen grapheme
	v fmt -w src/grapheme/grapheme_properties.v
	./gen/gen grapheme_breaktest
	v fmt -w src/grapheme/graphemebreak_test.v
	rm ./gen/gen

test:
	v -stats test src/.
