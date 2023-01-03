module util

import os

fn test_rune_iter_from_string() {
	str := 'a1©★🚀'
	mut rune_iter := rune_iter_from_string(str, false)

	r1, s1, e1 := rune_iter.next() or {
		assert false, 'expected first rune is not returned'
		` `, -1, -1
	}
	assert r1 == `a`
	assert s1 == 0
	assert e1 == 1

	r2, s2, e2 := rune_iter.next() or {
		assert false, 'expected second rune is not returned'
		` `, -1, -1
	}
	assert r2 == `1`
	assert s2 == 1
	assert e2 == 2

	r3, s3, e3 := rune_iter.next() or {
		assert false, 'expected third rune is not returned'
		` `, -1, -1
	}
	assert r3 == `©`
	assert s3 == 2
	assert e3 == 4

	r4, s4, e4 := rune_iter.next() or {
		assert false, 'expected fourth rune is not returned'
		` `, -1, -1
	}
	assert r4 == `★`
	assert s4 == 4
	assert e4 == 7

	r5, s5, e5 := rune_iter.next() or {
		assert false, 'expected fifth rune is not returned'
		` `, -1, -1
	}
	assert r5 == `🚀`
	assert s5 == 7
	assert e5 == 11

	r6, s6, e6 := rune_iter.next() or { ` `, -1, -1 }
	assert r6 == ` `
	assert s6 == -1
	assert e6 == -1
}

fn test_rune_iter_from_bytes() {
	str := 'a1©★🚀'
	mut rune_iter := rune_iter_from_bytes(str.bytes(), false)

	r1, s1, e1 := rune_iter.next() or {
		assert false, 'expected first rune is not returned'
		` `, -1, -1
	}
	assert r1 == `a`
	assert s1 == 0
	assert e1 == 1

	r2, s2, e2 := rune_iter.next() or {
		assert false, 'expected second rune is not returned'
		` `, -1, -1
	}
	assert r2 == `1`
	assert s2 == 1
	assert e2 == 2

	r3, s3, e3 := rune_iter.next() or {
		assert false, 'expected third rune is not returned'
		` `, -1, -1
	}
	assert r3 == `©`
	assert s3 == 2
	assert e3 == 4

	r4, s4, e4 := rune_iter.next() or {
		assert false, 'expected fourth rune is not returned'
		` `, -1, -1
	}
	assert r4 == `★`
	assert s4 == 4
	assert e4 == 7

	r5, s5, e5 := rune_iter.next() or {
		assert false, 'expected fifth rune is not returned'
		` `, -1, -1
	}
	assert r5 == `🚀`
	assert s5 == 7
	assert e5 == 11

	r6, s6, e6 := rune_iter.next() or { ` `, -1, -1 }
	assert r6 == ` `
	assert s6 == -1
	assert e6 == -1
}

fn test_rune_iter_from_bytes_rewindable() {
	str := 'a1©★🚀'
	mut rune_iter := rune_iter_from_bytes(str.bytes(), true)

	r1, s1, e1 := rune_iter.next() or {
		assert false, 'expected first rune is not returned'
		` `, -1, -1
	}
	assert r1 == `a`
	assert s1 == 0
	assert e1 == 1

	r2, s2, e2 := rune_iter.next() or {
		assert false, 'expected second rune is not returned'
		` `, -1, -1
	}
	assert r2 == `1`
	assert s2 == 1
	assert e2 == 2

	rune_iter.rewind(2)!

	r1_1, s1_1, e1_1 := rune_iter.next() or {
		assert false, 'expected first rune is not returned after rewind(2)'
		` `, -1, -1
	}
	assert r1_1 == `a`
	assert s1_1 == 0
	assert e1_1 == 1

	r2_1, s2_1, e2_1 := rune_iter.next() or {
		assert false, 'expected second rune is not returned after rewind(2)'
		` `, -1, -1
	}
	assert r2_1 == `1`
	assert s2_1 == 1
	assert e2_1 == 2

	r3, s3, e3 := rune_iter.next() or {
		assert false, 'expected third rune is not returned'
		` `, -1, -1
	}
	assert r3 == `©`
	assert s3 == 2
	assert e3 == 4

	r4, s4, e4 := rune_iter.next() or {
		assert false, 'expected fourth rune is not returned'
		` `, -1, -1
	}
	assert r4 == `★`
	assert s4 == 4
	assert e4 == 7

	r5, s5, e5 := rune_iter.next() or {
		assert false, 'expected fifth rune is not returned'
		` `, -1, -1
	}
	assert r5 == `🚀`
	assert s5 == 7
	assert e5 == 11

	rune_iter.rewind(1)!

	r5_1, s5_1, e5_1 := rune_iter.next() or {
		assert false, 'expected fifth rune is not returned after rewind(1)'
		` `, -1, -1
	}
	assert r5_1 == `🚀`
	assert s5_1 == 7
	assert e5_1 == 11

	r6, s6, e6 := rune_iter.next() or { ` `, -1, -1 }
	assert r6 == ` `
	assert s6 == -1
	assert e6 == -1
}

fn test_rune_iter_from_reader() {
	mut f := os.open('src/util/rune_iter_test_file.txt') or {
		panic('cannot open text file for testing')
	}
	defer {
		f.close()
	}
	mut rune_iter := rune_iter_from_reader(f, false)

	r1, s1, e1 := rune_iter.next() or {
		assert false, 'expected first rune is not returned'
		` `, -1, -1
	}
	assert r1 == `a`
	assert s1 == 0
	assert e1 == 1

	r2, s2, e2 := rune_iter.next() or {
		assert false, 'expected second rune is not returned'
		` `, -1, -1
	}
	assert r2 == `1`
	assert s2 == 1
	assert e2 == 2

	r3, s3, e3 := rune_iter.next() or {
		assert false, 'expected third rune is not returned'
		` `, -1, -1
	}
	assert r3 == `©`
	assert s3 == 2
	assert e3 == 4

	r4, s4, e4 := rune_iter.next() or {
		assert false, 'expected fourth rune is not returned'
		` `, -1, -1
	}
	assert r4 == `★`
	assert s4 == 4
	assert e4 == 7

	r5, s5, e5 := rune_iter.next() or {
		assert false, 'expected fifth rune is not returned'
		` `, -1, -1
	}
	assert r5 == `🚀`
	assert s5 == 7
	assert e5 == 11

	r6, s6, e6 := rune_iter.next() or { ` `, -1, -1 }
	assert r6.bytes() == ` `.bytes()
	assert s6 == -1
	assert e6 == -1
}

fn test_rune_iter_from_reader_rewindable() {
	mut f := os.open('src/util/rune_iter_test_file.txt') or {
		panic('cannot open text file for testing')
	}
	defer {
		f.close()
	}
	mut rune_iter := rune_iter_from_reader(f, true)

	r1, s1, e1 := rune_iter.next() or {
		assert false, 'expected first rune is not returned'
		` `, -1, -1
	}
	assert r1 == `a`
	assert s1 == 0
	assert e1 == 1

	r2, s2, e2 := rune_iter.next() or {
		assert false, 'expected second rune is not returned'
		` `, -1, -1
	}
	assert r2 == `1`
	assert s2 == 1
	assert e2 == 2

	rune_iter.rewind(2)!

	r1_1, s1_1, e1_1 := rune_iter.next() or {
		assert false, 'expected first rune is not returned after rewind(2)'
		` `, -1, -1
	}
	assert r1_1 == `a`
	assert s1_1 == 0
	assert e1_1 == 1

	r2_1, s2_1, e2_1 := rune_iter.next() or {
		assert false, 'expected second rune is not returned after rewind(2)'
		` `, -1, -1
	}
	assert r2_1 == `1`
	assert s2_1 == 1
	assert e2_1 == 2

	r3, s3, e3 := rune_iter.next() or {
		assert false, 'expected third rune is not returned'
		` `, -1, -1
	}
	assert r3 == `©`
	assert s3 == 2
	assert e3 == 4

	r4, s4, e4 := rune_iter.next() or {
		assert false, 'expected fourth rune is not returned'
		` `, -1, -1
	}
	assert r4 == `★`
	assert s4 == 4
	assert e4 == 7

	r5, s5, e5 := rune_iter.next() or {
		assert false, 'expected fifth rune is not returned'
		` `, -1, -1
	}
	assert r5 == `🚀`
	assert s5 == 7
	assert e5 == 11

	rune_iter.rewind(1)!

	r5_1, s5_1, e5_1 := rune_iter.next() or {
		assert false, 'expected fifth rune is not returned after rewind(1)'
		` `, -1, -1
	}
	assert r5_1 == `🚀`
	assert s5_1 == 7
	assert e5_1 == 11

	r6, s6, e6 := rune_iter.next() or { ` `, -1, -1 }
	assert r6.bytes() == ` `.bytes()
	assert s6 == -1
	assert e6 == -1
}

fn test_rune_iter_rewindable_errors() {
	str := 'a1©★🚀'
	mut rune_iter := rune_iter_from_bytes(str.bytes(), false)
	mut error_returned := false
	rune_iter.rewind(1) or { error_returned = true }
	assert error_returned, 'error should be returned when the rune_iter is not rewindable'

	rune_iter = rune_iter_from_bytes(str.bytes(), true)
	rune_iter.rewind(-1) or { error_returned = true }
	assert error_returned, 'error should be returned when the input count is negative'
}
