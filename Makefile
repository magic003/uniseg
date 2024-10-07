.DEFAULT_GOAL := all

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

gen-sentence:
	v gen/.
	./gen/gen sentence
	v fmt -w sentence/sentence_properties.v
	./gen/gen sentence_breaktest
	v fmt -w sentence/sentence_breaktest.v
	rm ./gen/gen

all: gen-grapheme gen-word gen-sentence

test:
	v -stats test .

vdoc:
	v doc -readme -f html -m . -o /tmp/ 
