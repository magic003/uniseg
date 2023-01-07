module sentence

import util

// State defines the states of the sentence boundary parser.
enum State {
	st_sot
	st_cr
	st_para_sep
	st_aterm
	st_sterm
	st_upper
	st_lower
	st_any
	st_eot
}

// check_boundary returns whether a sentence boundary can be added by consuming next a few runes,  given the
// current `state`. Some rules require to look ahead multiple runes. The `rune_iter` must be rewindable.
//
// It returns:
//   - The next state.
//   - Whether a boundary can be added before the last rune in the returned rune array.
//   - The runes consumed by this call.
fn check_boundary(state State, mut rune_iter util.RuneIter) (State, bool, []rune) {
	r, _, _ := rune_iter.next() or { return State.st_eot, true, []rune{} }
	sp := get_sentence_property(r)
	// SB5. Handle it here, so it doesn't repeat in each state below.
	if sp == SentenceProp.sp_format || sp == SentenceProp.sp_extend {
		// SB4
		if state in [State.st_cr, State.st_para_sep] {
			return State.st_any, true, [r]
		} else if state == State.st_sot {
			return State.st_any, false, [r]
		}

		return state, false, [r]
	}

	next_state := transition_state(sp)
	match state {
		// initial state. Not a boundary. Simply moves to the next state.
		.st_sot {
			return next_state, false, [r]
		}
		.st_cr {
			// SB3 and SB4
			return next_state, sp != SentenceProp.sp_lf, [r]
		}
		.st_para_sep {
			// SB4
			return next_state, true, [r]
		}
		.st_aterm {
			// SB6
			if sp == SentenceProp.sp_numeric {
				return State.st_any, false, [r]
			}
			mut runes_to_return := []rune{}
			mut next_rune := r
			mut next_sp := sp
			for next_sp == SentenceProp.sp_close || next_sp == SentenceProp.sp_format
				|| next_sp == SentenceProp.sp_extend {
				runes_to_return << next_rune
				next_rune, _, _ = rune_iter.next() or {
					return State.st_any, false, runes_to_return
				}
				next_sp = get_sentence_property(next_rune)
			}

			for next_sp == SentenceProp.sp_sp || next_sp == SentenceProp.sp_format
				|| next_sp == SentenceProp.sp_extend {
				runes_to_return << next_rune
				next_rune, _, _ = rune_iter.next() or {
					return State.st_any, false, runes_to_return
				}
				next_sp = get_sentence_property(next_rune)
			}

			// SB8a
			if next_sp in [SentenceProp.sp_scontinue, SentenceProp.sp_aterm, SentenceProp.sp_sterm] {
				runes_to_return << next_rune
				return transition_state(next_sp), false, runes_to_return
			}
			// SB8
			mut look_ahead_runes := [next_rune]
			for next_sp !in [SentenceProp.sp_oletter, SentenceProp.sp_upper, SentenceProp.sp_lower,
				SentenceProp.sp_lf, SentenceProp.sp_cr, SentenceProp.sp_sep, SentenceProp.sp_aterm,
				SentenceProp.sp_sterm] {
				next_rune, _, _ = rune_iter.next() or {
					rune_iter.rewind(look_ahead_runes.len - 1) or { panic(error) }
					runes_to_return << look_ahead_runes[0]
					return transition_state(get_sentence_property(look_ahead_runes[0])), true, runes_to_return
				}
				look_ahead_runes << next_rune
				next_sp = get_sentence_property(next_rune)
			}
			if next_sp == SentenceProp.sp_lower {
				runes_to_return << look_ahead_runes
				return State.st_lower, false, runes_to_return
			}
			// SB11
			if next_sp in [SentenceProp.sp_lf, SentenceProp.sp_cr, SentenceProp.sp_sep] {
				runes_to_return << look_ahead_runes
				return transition_state(next_sp), false, runes_to_return
			}

			rune_iter.rewind(look_ahead_runes.len - 1) or { panic(error) }
			runes_to_return << look_ahead_runes[0]
			return transition_state(get_sentence_property(look_ahead_runes[0])), true, runes_to_return
		}
		.st_sterm {
			mut runes_to_return := []rune{}
			mut next_rune := r
			mut next_sp := sp
			for next_sp == SentenceProp.sp_close || next_sp == SentenceProp.sp_format
				|| next_sp == SentenceProp.sp_extend {
				runes_to_return << next_rune
				next_rune, _, _ = rune_iter.next() or {
					return State.st_any, false, runes_to_return
				}
				next_sp = get_sentence_property(next_rune)
			}

			for next_sp == SentenceProp.sp_sp || next_sp == SentenceProp.sp_format
				|| next_sp == SentenceProp.sp_extend {
				runes_to_return << next_rune
				next_rune, _, _ = rune_iter.next() or {
					return State.st_any, false, runes_to_return
				}
				next_sp = get_sentence_property(next_rune)
			}

			runes_to_return << next_rune
			// SB8a
			if next_sp in [SentenceProp.sp_scontinue, SentenceProp.sp_aterm, SentenceProp.sp_sterm] {
				return transition_state(next_sp), false, runes_to_return
			}
			// SB11
			if next_sp in [SentenceProp.sp_lf, SentenceProp.sp_cr, SentenceProp.sp_sep] {
				return transition_state(next_sp), false, runes_to_return
			}

			return transition_state(next_sp), true, runes_to_return
		}
		.st_upper, .st_lower {
			// SB7
			if sp == SentenceProp.sp_aterm {
				mut look_ahead_runes := []rune{}
				for {
					look_ahead_rune, _, _ := rune_iter.next() or {
						rune_iter.rewind(look_ahead_runes.len) or { panic(error) }
						return State.st_aterm, false, [r]
					}
					look_ahead_prop := get_sentence_property(look_ahead_rune)
					look_ahead_runes << look_ahead_rune
					if look_ahead_prop in [SentenceProp.sp_format, SentenceProp.sp_extend] {
						continue
					}
					if look_ahead_prop == SentenceProp.sp_upper {
						look_ahead_runes.prepend(r)
						return State.st_upper, false, look_ahead_runes
					}
					break
				}
				rune_iter.rewind(look_ahead_runes.len) or { panic(error) }
				return State.st_aterm, false, [r]
			}
			return next_state, false, [r]
		}
		.st_any {
			// SB998
			return next_state, false, [r]
		}
		.st_eot { // this should never be reached.
			return State.st_eot, true, []rune{}
		}
	}
}

// get_sentence_property returns the `SentenceProp` of a `r`une, via a binary search of the `sentence_properties` array.
fn get_sentence_property(r rune) SentenceProp {
	v := int(r)
	mut low := 0
	mut high := sentence_properties.len - 1
	for low <= high {
		mid := low + (high - low) / 2
		code_point := sentence_properties[mid]
		if v >= code_point.from && v <= code_point.to {
			return code_point.property
		} else if v < code_point.from {
			high = mid - 1
		} else {
			low = mid + 1
		}
	}

	return .sp_any
}

// transition_state returns the next state based on the current sentence property.
fn transition_state(gp SentenceProp) State {
	match gp {
		.sp_cr {
			return State.st_cr
		}
		.sp_sep, .sp_lf {
			return State.st_para_sep
		}
		.sp_sterm {
			return State.st_sterm
		}
		.sp_aterm {
			return State.st_aterm
		}
		.sp_upper {
			return State.st_upper
		}
		.sp_lower {
			return State.st_lower
		}
		else {
			return State.st_any
		}
	}
}
