# SwiftStringScore
SwiftStringScore is a swift extension which provides super fast fuzzy string matching/scoring.

Based on the Objective-C implementation of Nicholas Bruning [https://github.com/thetron/StringScore](https://github.com/thetron/StringScore)  
and the original JavaScript implementation of Joshaven Potter [https://github.com/joshaven/string_score](https://github.com/joshaven/string_score)

Works with swift 2.2 or newer.


## Usage

Just add the `String+Score.swift` file into your swift project and you're ready to go!


## Examples
```
"hello world".scoreAgainst("axl") // => 0
"hello world".scoreAgainst("ow") // => 0.3545455

// Single letter match
"hello world".scoreAgainst("e") // => 0.1090909

// Single letter match plus bonuses for beginning of word and beginning of phrase
"hello world".scoreAgainst("h") // => 0.5863637
"hello world".scoreAgainst("w") // => 0.5454546

"hello world".scoreAgainst("he") // => 0.6227273
"hello world".scoreAgainst("hel") // => 0.6590909
"hello world".scoreAgainst("hell") // => 0.6954546
"hello world".scoreAgainst("hello") // => 0.7318182
"hello world".scoreAgainst("hello ") // => 0.7681818
"hello world".scoreAgainst("hello w") // => 0.8045455
"hello world".scoreAgainst("hello wo") // => 0.8409091
"hello world".scoreAgainst("hello wor") // => 0.8772728
"hello world".scoreAgainst("hello worl") // => 0.9136364
"hello world".scoreAgainst("hello world") // => 1.0

// Using a "1" in place of an "l" is a mismatch unless the score is fuzzy
"hello world".scoreAgainst("hello wor1") // => 0
"hello world".scoreAgainst("hello wor1", fuzziness: 0.5) // => 0.6145455 (fuzzy)

// Finding a match in a shorter string is more significant.
"Hello".scoreAgainst("h") // => 0.5700001
"He".scoreAgainst("h") // => 0.6750001

// Same case matches better than wrong case
"Hello".scoreAgainst("h") // => 0.5700001
"Hello".scoreAgainst("H") // => 0.63

// Acronyms are given a little more weight
"Hillsdale Michigan".scoreAgainst("HiMi") > "Hillsdale Michigan".scoreAgainst("Hills")
"Hillsdale Michigan".scoreAgainst("HiMi") < "Hillsdale Michigan".scoreAgainst("Hillsd")

// Unicode supported
"🐱".scoreAgainst("🐱") // => 1
"🐱".scoreAgainst("🐼") // => 0
"🐱🙃".scoreAgainst("🙃") // => 0.15
"🐱🙃".scoreAgainst("🐱") // => 0.75
```