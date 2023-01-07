# Unicode Text Segmentation in V
This vlang package implements Unicode Text Segmentation according to [Unicode Standard Annex #29](http://www.unicode.org/reports/tr29/).

## Status
* [Grapheme cluster boundaries](http://www.unicode.org/reports/tr29/#Grapheme_Cluster_Boundaries): supported and passed official break tests.
* [Word boundaries](http://www.unicode.org/reports/tr29/#Word_Boundaries): supported and passed official break tests.
* [Sentence boundaries](http://www.unicode.org/reports/tr29/#Sentence_Boundaries): supported and passed official break tests.

## Installation
```shell
v install magic003.uniseg
```

## Examples
Check out the `examples` folder.

## Documentation
Refer to http://magic003.github.io/uniseg for the documentation.

## References
- [Unicode Standard Annex #29](http://www.unicode.org/reports/tr29/).
- The design and implementation of this library is heavily influenced by [uniseg in Go](https://github.com/rivo/uniseg) and [unicode-segmentation in Rust](https://github.com/unicode-rs/unicode-segmentation).
