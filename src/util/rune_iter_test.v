module util

fn test_rune_iter_from_string() {
	str := 'a1©★🚀'
	mut rune_iter := rune_iter_from_string(str)

	r1, s1, e1 := rune_iter.next() or { panic('expected first rune is not returned') }
	assert r1 == `a`
	assert s1 == 0
	assert e1 == 1

	r2, s2, e2 := rune_iter.next() or { panic('expected second rune is not returned') }
	assert r2 == `1`
	assert s2 == 1
	assert e2 == 2

	r3, s3, e3 := rune_iter.next() or { panic('expected third rune is not returned') }
	assert r3 == `©`
	assert s3 == 2
	assert e3 == 4

	r4, s4, e4 := rune_iter.next() or { panic('expected fourth rune is not returned') }
	assert r4 == `★`
	assert s4 == 4
	assert e4 == 7

	r5, s5, e5 := rune_iter.next() or { panic('expected fifth rune is not returned') }
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
	mut rune_iter := rune_iter_from_bytes(str.bytes())

	r1, s1, e1 := rune_iter.next() or { panic('expected first rune is not returned') }
	assert r1 == `a`
	assert s1 == 0
	assert e1 == 1

	r2, s2, e2 := rune_iter.next() or { panic('expected second rune is not returned') }
	assert r2 == `1`
	assert s2 == 1
	assert e2 == 2

	r3, s3, e3 := rune_iter.next() or { panic('expected third rune is not returned') }
	assert r3 == `©`
	assert s3 == 2
	assert e3 == 4

	r4, s4, e4 := rune_iter.next() or { panic('expected fourth rune is not returned') }
	assert r4 == `★`
	assert s4 == 4
	assert e4 == 7

	r5, s5, e5 := rune_iter.next() or { panic('expected fifth rune is not returned') }
	assert r5 == `🚀`
	assert s5 == 7
	assert e5 == 11

	r6, s6, e6 := rune_iter.next() or { ` `, -1, -1 }
	assert r6 == ` `
	assert s6 == -1
	assert e6 == -1
}
