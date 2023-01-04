module grapheme

// State defines the states of the grapheme cluster parser.
enum State {
	st_sot
	st_cr
	st_control_lf
	st_l
	st_lvv
	st_lvtt
	st_prepend
	st_extended_pictographic
	st_extended_pictographic_zwj
	st_ri_odd
	st_ri_even
	st_any
	st_eot
}

// check_boundary returns whether a boundary can be added before the `r`une given the current `state`.
// It returns the next state as well.
fn check_boundary(state State, r rune) (State, bool) {
	gp := get_grapheme_property(r)
	next_state := transition_state(state, gp)
	match state {
		// initial state. Not a boundary. Simply moves to the next state.
		.st_sot {
			return next_state, false
		}
		.st_cr {
			match gp {
				// GB3
				.gp_lf { return State.st_control_lf, false }
				// GB4
				else { return next_state, true }
			}
		}
		.st_control_lf {
			// GB4
			return next_state, true
		}
		.st_l {
			match gp {
				// GB6
				.gp_l, .gp_v, .gp_lv, .gp_lvt { return next_state, false }
				// GB9
				.gp_extend, .gp_zwj { return next_state, false }
				// GB9a
				.gp_spacingmark { return next_state, false }
				else { return next_state, true }
			}
		}
		.st_lvv {
			match gp {
				// GB7
				.gp_v, .gp_t { return next_state, false }
				// GB9
				.gp_extend, .gp_zwj { return next_state, false }
				// GB9a
				.gp_spacingmark { return next_state, false }
				else { return next_state, true }
			}
		}
		.st_lvtt {
			match gp {
				// GB8
				.gp_t { return next_state, false }
				// GB9
				.gp_extend, .gp_zwj { return next_state, false }
				// GB9a
				.gp_spacingmark { return next_state, false }
				else { return next_state, true }
			}
		}
		.st_prepend {
			match gp {
				// GB5
				.gp_control, .gp_cr, .gp_lf { return next_state, true }
				else { return next_state, false }
			}
		}
		.st_extended_pictographic {
			match gp {
				// GB11
				.gp_extend { return State.st_extended_pictographic, false }
				.gp_zwj { return State.st_extended_pictographic_zwj, false }
				// GB9a
				.gp_spacingmark { return next_state, false }
				else { return next_state, true }
			}
		}
		.st_extended_pictographic_zwj {
			match gp {
				// GB11
				.gp_extended_pictographic { return State.st_extended_pictographic, false }
				// GB9
				.gp_extend, .gp_zwj { return next_state, false }
				// GB9a
				.gp_spacingmark { return next_state, false }
				else { return next_state, true }
			}
		}
		.st_ri_odd {
			match gp {
				// GB12 GB13
				.gp_regional_indicator { return State.st_ri_even, false }
				// GB9
				.gp_extend, .gp_zwj { return next_state, false }
				// GB9a
				.gp_spacingmark { return next_state, false }
				else { return next_state, true }
			}
		}
		.st_ri_even {
			match gp {
				// GB9
				.gp_extend, .gp_zwj { return next_state, false }
				// GB9a
				.gp_spacingmark { return next_state, false }
				else { return next_state, true }
			}
		}
		.st_any {
			match gp {
				// GB9
				.gp_extend, .gp_zwj { return next_state, false }
				// GB9a
				.gp_spacingmark { return next_state, false }
				// GB999
				else { return next_state, true }
			}
		}
		.st_eot { // this should never be reached.
			return State.st_eot, true
		}
	}
}

// get_grapheme_property returns the `GraphemeProp` of a `r`une, via a binary search of the `grapheme_properties` array.
fn get_grapheme_property(r rune) GraphemeProp {
	v := int(r)
	mut low := 0
	mut high := grapheme_properties.len - 1
	for low <= high {
		mid := low + (high - low) / 2
		code_point := grapheme_properties[mid]
		if v >= code_point.from && v <= code_point.to {
			return code_point.property
		} else if v < code_point.from {
			high = mid - 1
		} else {
			low = mid + 1
		}
	}

	return .gp_any
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
