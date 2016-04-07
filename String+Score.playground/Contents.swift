//
//  String+Score.playground
//
//  Created by Dominik Felber on 07.04.2016.
//  Copyright (c) 2016 Dominik Felber. All rights reserved.
//
//  Based on the Objective-C implementation of Nicholas Bruning https://github.com/thetron/StringScore
//  and the original JavaScript implementation of Joshaven Potter https://github.com/joshaven/string_score
// 


import Foundation


enum StringScoreOption {
    case None
    case FavorSmallerWords
    case ReducedLongStringPenalty
}


extension String
{
    /// Calculates a score describing how good two strings match.
    /// (0 => no match / 1 => perfect match)
    ///
    /// - parameter otherString:    The string to compare to
    /// - parameter fuzziness:      How fuzzy the matching calculation is (0...1)
    /// - parameter option:         Optional comparison options
    /// - returns:                  A Float in the range of 0...1
    ///
    func scoreAgainst(otherString: String, fuzziness: Float? = nil, option: StringScoreOption = .None) -> Float
    {
        // Both strings are identical
        if self == otherString {
            return 1
        }
        
        // Other string is empty
        if otherString.isEmpty {
            return 0
        }
        
        let otherStringLength = Float(otherString.characters.count)
        let stringLength = Float(self.characters.count)
        
        var totalCharacterScore: Float = 0
        var otherStringScore: Float = 0
        var fuzzies: Float = 1
        var finalScore: Float = 0
        var workingString = self
        var startOfStringBonus = false
        
        // Ensure that the fuzziness is in the range of 0...1
        var fuzzyFactor = fuzziness
        if let f = fuzzyFactor {
            fuzzyFactor = 1 - max(min(1.0, f), 0.0)
        }
        
        
        for (index, character) in otherString.characters.enumerate()
        {
            var characterScore: Float = 0.1
            let indexInString = workingString.rangeOfString("\(character)", options: .CaseInsensitiveSearch, range: workingString.startIndex..<workingString.endIndex, locale: nil)
            
            if let indexInString = indexInString {
                // Same case bonus
                let char = workingString.characters[indexInString.startIndex]
                if character == char {
                    characterScore += 0.1
                }
                
                // Consecutive letter & start-of-string bonus
                if indexInString.startIndex == otherString.startIndex {
                    // Increase the score when matching first character of the remainder of the string
                    characterScore += 0.6
                    
                    // If match is the first character of the string
                    // & the first character of abbreviation, add a
                    // start-of-string match bonus.
                    if index == 0 {
                        startOfStringBonus = true
                    }
                } else {
                    // Acronym Bonus
                    // Weighing Logic: Typing the first character of an acronym is as if you
                    // preceded it with two perfect character matches.
                    if workingString.substringWithRange(indexInString.startIndex.advancedBy(-1)..<indexInString.endIndex.advancedBy(-1)) == " " {
                        characterScore += 0.8
                    }
                }
                
                // Left trim the already matched part of the string
                // (forces sequential matching).
                workingString = workingString.substringFromIndex(indexInString.startIndex.advancedBy(1))
            } else {
                if let fuzzyFactor = fuzzyFactor {
                    fuzzies += fuzzyFactor
                } else {
                    return 0
                }
            }
            
            totalCharacterScore += characterScore
        }
        
        if option == .FavorSmallerWords {
            // Weigh smaller words higher
            return totalCharacterScore / stringLength
        }
        
        otherStringScore = totalCharacterScore / otherStringLength
        
        if option == .ReducedLongStringPenalty {
            // Reduce the penalty for longer words
            let percentageOfMatchedString = otherStringLength / stringLength
            let wordScore = otherStringScore * percentageOfMatchedString
            finalScore = (wordScore + otherStringScore) / 2
        } else {
            finalScore = ((otherStringScore * otherStringLength / stringLength) + otherStringScore) / 2
        }
        
        finalScore = finalScore / fuzzies
        
        if startOfStringBonus && finalScore + 0.15 < 1 {
            finalScore += 0.15
        }
        
        return finalScore
    }
}


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
"🐱".scoreAgainst("🙃") // => 0
"🐱🙃".scoreAgainst("🙃") // => 0.15
"🐱🙃".scoreAgainst("🐱") // => 0.75
