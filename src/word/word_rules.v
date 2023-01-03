module word

import util

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
	st_numeric
	st_katakana
	st_extendnumlet
	st_ri_odd
	st_ri_even
	st_any
	st_eot
}

// check_boundary returns whether a word boundary can be added by consuming next a few runes,  given the current `state`.
// Some rules requires to look ahead multiple runes. The `rune_iter` must be rewindable.
//
// It returns:
//   - The next state.
//   - Whether a boundary can be added before the last rune in the returned rune array.
//   - The runes consumed by this call.
fn check_boundary(state State, mut rune_iter util.RuneIter) (State, bool, []rune) {
	r, _, _ := rune_iter.next() or { return State.st_eot, true, []rune{} }
	wp := get_word_property(r)
	// special logic for ZWJ character because it is used in both WB3c and WB4.
	if wp == WordProp.wp_zwj && state !in [State.st_zwj, State.st_extend_format] {
		// WB4: ZWJ should not be ignored after sot, CR, LF and Newline.
		if state in [State.st_cr, State.st_newline_lf] {
			return State.st_zwj, true, [r]
		} else if state == State.st_sot {
			return State.st_zwj, false, [r]
		}

		// WB3c has precedence over WB4. WB4 ignores ZWJ and uses the previous state. However, WB3c needs to know if
		// the previous character is ZWJ. So ZWJ should not be ignored always. Here, it looks ahead and only ignore
		// ZWJ if it doesn't meet WB3c.
		next_rune, _, _ := rune_iter.next() or { return state, false, [r] }
		// WB3c
		if get_word_property(next_rune) == WordProp.wp_extended_pictographic {
			// alternatively, this can return st_zwj and rewind it. It'll reach the same state in a subsequent call.
			return State.st_any, false, [r, next_rune]
		} else {
			// WB4: ignore ZWJ and return the previous state.
			rune_iter.rewind(1) or { panic(error) }

			if state == State.st_wsegspace {
				return State.st_any, false, [r]
			}
			return state, false, [r]
		}
	}

	// special logic for format and extend characters, so it doesn't repeat in each state below.
	if (wp == WordProp.wp_format || wp == WordProp.wp_extend)
		&& state !in [State.st_zwj, State.st_extend_format] {
		// WB4: Format and Extend should not be ignored after sot, CR, LF and Newline.
		if state in [State.st_cr, State.st_newline_lf] {
			return State.st_extend_format, true, [r]
		} else if state == State.st_sot {
			return State.st_extend_format, false, [r]
		}

		// for test case: ÷ [0.2] SPACE (WSegSpace) × [4.0] COMBINING DIAERESIS (Extend_FE) ÷ [999.0] SPACE (WSegSpace) ÷ [0.3]
		if state == State.st_wsegspace {
			return State.st_any, false, [r]
		}

		// WB4: ignore Format and Extend, and return the previous state.
		return state, false, [r]
	}

	next_state := transition_state(state, wp)
	match state {
		// initial state. Not a boundary. Simply moves to the next state.
		.st_sot {
			return next_state, false, [r]
		}
		.st_cr {
			// WB3 and WB3a
			return next_state, wp != WordProp.wp_lf, [r]
		}
		.st_newline_lf {
			// WB3a
			return next_state, true, [r]
		}
		.st_zwj {
			// WB3c
			if wp == WordProp.wp_extended_pictographic {
				return State.st_any, false, [r]
			}
			// WB4: when not ignorable, the format, extend and ZWJ characters should be collpased and returned as
			// a single unit. The rule doesn't say this explicitly, but the test cases indicate it.
			if wp in [WordProp.wp_format, WordProp.wp_extend, WordProp.wp_zwj] {
				return next_state, false, [r]
			}

			return next_state, true, [r]
		}
		.st_wsegspace {
			// WB3d
			return next_state, wp != WordProp.wp_wsegspace, [r]
		}
		.st_extend_format {
			// WB4: when not ignorable, the format, extend and ZWJ characters should be collpased and returned as
			// a single unit. The rule doesn't say this explicitly, but the test cases indicate it.
			if wp in [WordProp.wp_format, WordProp.wp_extend, WordProp.wp_zwj] {
				return next_state, false, [r]
			}

			return next_state, true, [r]
		}
		.st_aletter {
			// WB5
			if wp == WordProp.wp_aletter || wp == WordProp.wp_hebrew_letter {
				return next_state, false, [r]
			}
			// WB9
			if wp == WordProp.wp_numeric {
				return next_state, false, [r]
			}
			// WB13a
			if wp == WordProp.wp_extendnumlet {
				return next_state, false, [r]
			}
			// WB6, WB7
			if wp in [WordProp.wp_midletter, WordProp.wp_midnumlet, WordProp.wp_single_quote] {
				mut look_ahead_runes := []rune{}
				for {
					next_rune, _, _ := rune_iter.next() or {
						rune_iter.rewind(look_ahead_runes.len) or { panic(error) }
						return next_state, true, [r]
					}
					next_prop := get_word_property(next_rune)
					look_ahead_runes << next_rune
					// WB4
					if next_prop in [WordProp.wp_format, WordProp.wp_extend, WordProp.wp_zwj] {
						continue
					}
					if next_prop == WordProp.wp_aletter || next_prop == WordProp.wp_hebrew_letter {
						look_ahead_runes.prepend(r)
						return transition_state(next_state, next_prop), false, look_ahead_runes
					}
					break
				}

				rune_iter.rewind(look_ahead_runes.len) or { panic(error) }
			}
			return next_state, true, [r]
		}
		.st_hebrew_letter {
			// WB5
			if wp == WordProp.wp_aletter || wp == WordProp.wp_hebrew_letter {
				return next_state, false, [r]
			}
			// WB9
			if wp == WordProp.wp_numeric {
				return next_state, false, [r]
			}
			// WB13a
			if wp == WordProp.wp_extendnumlet {
				return next_state, false, [r]
			}
			// WB6, WB7
			if wp in [WordProp.wp_midletter, WordProp.wp_midnumlet] {
				mut look_ahead_runes := []rune{}
				for {
					next_rune, _, _ := rune_iter.next() or {
						rune_iter.rewind(look_ahead_runes.len) or { panic(error) }
						return next_state, true, [r]
					}
					next_prop := get_word_property(next_rune)
					look_ahead_runes << next_rune
					// WB4
					if next_prop in [WordProp.wp_format, WordProp.wp_extend, WordProp.wp_zwj] {
						continue
					}
					if next_prop == WordProp.wp_aletter || next_prop == WordProp.wp_hebrew_letter {
						look_ahead_runes.prepend(r)
						return transition_state(next_state, next_prop), false, look_ahead_runes
					}
					break
				}

				rune_iter.rewind(look_ahead_runes.len) or { panic(error) }
			}
			// WB7a
			if wp == WordProp.wp_single_quote {
				return next_state, false, [r]
			}
			// WB7b, WB7c
			if wp == WordProp.wp_double_quote {
				mut look_ahead_runes := []rune{}
				for {
					next_rune, _, _ := rune_iter.next() or {
						rune_iter.rewind(look_ahead_runes.len) or { panic(error) }
						return next_state, true, [r]
					}
					next_prop := get_word_property(next_rune)
					look_ahead_runes << next_rune
					// WB4
					if next_prop in [WordProp.wp_format, WordProp.wp_extend, WordProp.wp_zwj] {
						continue
					}
					if next_prop == WordProp.wp_hebrew_letter {
						look_ahead_runes.prepend(r)
						return transition_state(next_state, next_prop), false, look_ahead_runes
					}
					break
				}

				rune_iter.rewind(look_ahead_runes.len) or { panic(error) }
			}
			return next_state, true, [r]
		}
		.st_numeric {
			// WB8
			if wp == WordProp.wp_numeric {
				return next_state, false, [r]
			}
			// WB10
			if wp == WordProp.wp_aletter || wp == WordProp.wp_hebrew_letter {
				return next_state, false, [r]
			}
			// WB11, WB12
			if wp in [WordProp.wp_midnum, WordProp.wp_midnumlet, WordProp.wp_single_quote] {
				mut look_ahead_runes := []rune{}
				for {
					next_rune, _, _ := rune_iter.next() or {
						rune_iter.rewind(look_ahead_runes.len) or { panic(error) }
						return next_state, true, [r]
					}
					next_prop := get_word_property(next_rune)
					look_ahead_runes << next_rune
					// WB4
					if next_prop in [WordProp.wp_format, WordProp.wp_extend, WordProp.wp_zwj] {
						continue
					}
					if next_prop == WordProp.wp_numeric {
						look_ahead_runes.prepend(r)
						return transition_state(next_state, next_prop), false, look_ahead_runes
					}
					break
				}

				rune_iter.rewind(look_ahead_runes.len) or { panic(error) }
			}

			// WB13a
			if wp == WordProp.wp_extendnumlet {
				return next_state, false, [r]
			}
			return next_state, true, [r]
		}
		.st_katakana {
			// WB13
			if wp == WordProp.wp_katakana {
				return next_state, false, [r]
			}
			// WB13a
			if wp == WordProp.wp_extendnumlet {
				return next_state, false, [r]
			}
			return next_state, true, [r]
		}
		.st_extendnumlet {
			// WB13a
			if wp == WordProp.wp_extendnumlet {
				return next_state, false, [r]
			}
			// WB13b
			if wp in [WordProp.wp_aletter, WordProp.wp_hebrew_letter, WordProp.wp_numeric,
				WordProp.wp_katakana] {
				return next_state, false, [r]
			}
			return next_state, true, [r]
		}
		.st_ri_odd {
			// WB15, WB16
			if wp == WordProp.wp_regional_indicator {
				return State.st_ri_even, false, [r]
			}
			return next_state, true, [r]
		}
		.st_ri_even {
			return next_state, true, [r]
		}
		.st_any {
			// WB999
			return next_state, true, [r]
		}
		.st_eot { // this should never be reached.
			return State.st_eot, true, []rune{}
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

// transition_state returns the next state based on the current state and word property.
fn transition_state(state State, gp WordProp) State {
	match gp {
		.wp_cr {
			return State.st_cr
		}
		.wp_newline, .wp_lf {
			return State.st_newline_lf
		}
		.wp_wsegspace {
			return State.st_wsegspace
		}
		.wp_numeric {
			return State.st_numeric
		}
		.wp_aletter {
			return State.st_aletter
		}
		.wp_extendnumlet {
			return State.st_extendnumlet
		}
		.wp_hebrew_letter {
			return State.st_hebrew_letter
		}
		.wp_katakana {
			return State.st_katakana
		}
		.wp_zwj {
			return State.st_zwj
		}
		.wp_format, .wp_extend {
			return State.st_extend_format
		}
		.wp_regional_indicator {
			return if state == State.st_ri_odd {
				State.st_ri_even
			} else {
				State.st_ri_odd
			}
		}
		else {
			return State.st_any
		}
	}
}
