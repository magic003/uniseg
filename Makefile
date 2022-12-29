gen-grapheme:
	v gen/.
	./gen/gen grapheme
	v fmt -w src/grapheme/grapheme_properties.v
	./gen/gen grapheme_breaktest
	v fmt -w src/grapheme/grapheme_breaktest.v
	rm ./gen/gen

gen-word:
	v gen/.
	./gen/gen word 
	v fmt -w src/word/word_properties.v
	rm ./gen/gen

test:
	v -stats test src/.
