module word

// State defines the states of the word boundary parser.
enum State {
	st_sot
	st_cr
	st_newline_lf
	st_zwj // non-ignorable ZWJ when WB4 doesnt' apply.
	st_wsegspace
	st_extend_format // non-ignorable extend and format characters when WB4 doesn't apply.
	st_aletter
	st_hebrew_letter
	st_single_quote
	st_numeric
	st_katakana
	st_extendnumlet
	st_ri_odd
	st_ri_even
	st_any
	st_eot
}

// check_boundary returns whether a word boundary can be added before the `r`une given the current `state`.
// It returns the next state as well.
fn check_boundary(state State, r rune) (State, bool) {
	wp := get_word_property(r)
	next_state := transition_state(state, wp)
	match state {
		// initial state. Not a boundary. Simply moves to the next state.
		.st_sot {
			return next_state, false
		}
		.st_eot { // this should never be reached.
			return State.st_eot, true
		}
	}
}

// get_word_property returns the `WordProp` of a `r`une, via a binary search of the `word_properties` array.
fn get_word_property(r rune) WordProp {
	v := int(r)
	mut low := 0
	mut high := word_properties.len - 1
	for low <= high {
		mid := low + (high - low) / 2
		code_point := word_properties[mid]
		if v >= code_point.from && v <= code_point.to {
			return code_point.property
		} else if v < code_point.from {
			high = mid - 1
		} else {
			low = mid + 1
		}
	}

	return .wp_any
}

// transition_state returns the next state based on the current state and grapheme property.
fn transition_state(state State, gp GraphemeProp) State {
	match gp {
		.gp_control, .gp_lf { return .st_control_lf }
		.gp_cr { return .st_cr }
		.gp_extended_pictographic { return .st_extended_pictographic }
		.gp_prepend { return .st_prepend }
		.gp_l { return .st_l }
		.gp_v, .gp_lv { return .st_lvv }
		.gp_t, .gp_lvt { return .st_lvtt }
		.gp_regional_indicator { return if state == .st_ri_odd { .st_ri_even } else { .st_ri_odd } }
		else { return .st_any }
	}
}
