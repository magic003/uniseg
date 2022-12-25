module grapheme

// StateKind defines the states of the grapheme cluster parser.
enum StateKind {
	st_sot
	st_cr
	st_control_lf
	st_l
	st_lvv
	st_lvtt
	st_any
	st_prepend
	st_extended_pictographic
	st_extended_pictographic_zwj
	st_ri_odd
	st_ri_even
	st_eot
}

// State keeps the parser state and whether it is boundary.
struct State {
	kind        StateKind [required]
	is_boundary bool      [required]
}
