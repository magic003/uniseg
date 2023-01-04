gen-grapheme:
	v gen/.
	./gen/gen grapheme
	v fmt -w grapheme/grapheme_properties.v
	./gen/gen grapheme_breaktest
	v fmt -w grapheme/grapheme_breaktest.v
	rm ./gen/gen

gen-word:
	v gen/.
	./gen/gen word 
	v fmt -w word/word_properties.v
	./gen/gen word_breaktest
	v fmt -w word/word_breaktest.v
	rm ./gen/gen

test:
	v -stats test .
