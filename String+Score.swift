//
//  String+Score.swift
//
//  Created by Dominik Felber on 07.04.2016.
//  Copyright (c) 2016 Dominik Felber. All rights reserved.
//
//  Based on the Objective-C implementation of Nicholas Bruning https://github.com/thetron/StringScore
//  and the original JavaScript implementation of Joshaven Potter https://github.com/joshaven/string_score
//

import Foundation


enum StringScoreOption {
    case none
    case favorSmallerWords
    case reducedLongStringPenalty
}


extension String
{
    /// Calculates a score describing how good two strings match.
    /// (0 => no match / 1 => perfect match)
    ///
    /// - Parameters:
    ///   - otherString: The string to compare to
    ///   - fuzziness: How fuzzy the matching calculation is (0...1)
    ///   - option: Optional comparison options
    ///
    /// - Returns: A Float in the range of 0...1
    ///
    func scoreAgainst(_ otherString: String, fuzziness: Float = 0, option: StringScoreOption = .none) -> Float
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
        let fuzzyFactor = 1 - max(min(1.0, fuzziness), 0.0)
        
        for (index, character) in otherString.characters.enumerated() {
            let range = workingString.characters.indices.startIndex ..< workingString.characters.indices.endIndex
            let indexInString = workingString.range(of: "\(character)", options: .caseInsensitive, range: range, locale: nil)

            var characterScore: Float = 0.1
            
            if let indexInString = indexInString {
                // Same case bonus
                let char = workingString.characters[indexInString.lowerBound]
                if character == char {
                    characterScore += 0.1
                }
                
                // Consecutive letter & start-of-string bonus
                if indexInString.lowerBound == otherString.startIndex {
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
                    let lowerBound = workingString.index(before: indexInString.lowerBound)
                    let upperBound = workingString.index(before: indexInString.upperBound)

                    if workingString.substring(with: lowerBound ..< upperBound) == " " {
                        characterScore += 0.8
                    }
                }
                
                // Left trim the already matched part of the string
                // (forces sequential matching).
                let lowerBound = workingString.index(after: indexInString.lowerBound)

                workingString = workingString.substring(from: lowerBound)
            } else {
                if fuzziness > 0 {
                    fuzzies += fuzzyFactor
                } else {
                    return 0
                }
            }
            
            totalCharacterScore += characterScore
        }
        
        if option == .favorSmallerWords {
            // Weigh smaller words higher
            return totalCharacterScore / stringLength
        }
        
        otherStringScore = totalCharacterScore / otherStringLength
        
        if option == .reducedLongStringPenalty {
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
