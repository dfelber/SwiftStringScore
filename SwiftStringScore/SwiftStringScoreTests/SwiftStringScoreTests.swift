//
//  SwiftStringScoreTests.swift
//  SwiftStringScoreTests
//
//  Created by Dominik Felber on 08.04.16.
//  Copyright © 2016 Dominik Felber. All rights reserved.
//

import XCTest
@testable import SwiftStringScore


// TODO: Define testcases and test

class SwiftStringScoreTests: XCTestCase
{
    func testScores()
    {
        XCTAssert("hello world".scoreAgainst("axl") == 0)
        XCTAssert("hello world".scoreAgainst("ow").aboutEqual(0.3545455))
        
        // Single letter match
        XCTAssert("hello world".scoreAgainst("e").aboutEqual(0.1090909))
        
        // Single letter match plus bonuses for beginning of word and beginning of phrase
        XCTAssert("hello world".scoreAgainst("h").aboutEqual(0.5863637))
        XCTAssert("hello world".scoreAgainst("w").aboutEqual(0.5454546))
        
        XCTAssert("hello world".scoreAgainst("he").aboutEqual(0.6227273))
        XCTAssert("hello world".scoreAgainst("hel").aboutEqual(0.6590909))
        XCTAssert("hello world".scoreAgainst("hell").aboutEqual(0.6954546))
        XCTAssert("hello world".scoreAgainst("hello").aboutEqual(0.7318182))
        XCTAssert("hello world".scoreAgainst("hello ").aboutEqual(0.7681818))
        XCTAssert("hello world".scoreAgainst("hello w").aboutEqual(0.8045455))
        XCTAssert("hello world".scoreAgainst("hello wo").aboutEqual(0.8409091))
        XCTAssert("hello world".scoreAgainst("hello wor").aboutEqual(0.8772728))
        XCTAssert("hello world".scoreAgainst("hello worl").aboutEqual(0.9136364))
        XCTAssert("hello world".scoreAgainst("hello world") == 1.0)
        
        // Using a "1" in place of an "l" is a mismatch unless the score is fuzzy
        XCTAssert("hello world".scoreAgainst("hello wor1") == 0)
        XCTAssert("hello world".scoreAgainst("hello wor1", fuzziness: 0.5).aboutEqual(0.6145455))
        
        // Finding a match in a shorter string is more significant.
        XCTAssert("Hello".scoreAgainst("h").aboutEqual(0.5700001))
        XCTAssert("He".scoreAgainst("h").aboutEqual(0.6750001))
        
        // Same case matches better than wrong case
        XCTAssert("Hello".scoreAgainst("h").aboutEqual(0.5700001))
        XCTAssert("Hello".scoreAgainst("H").aboutEqual(0.63))
        
        // Acronyms are given a little more weight
        XCTAssert("Hillsdale Michigan".scoreAgainst("HiMi") > "Hillsdale Michigan".scoreAgainst("Hills"))
        XCTAssert("Hillsdale Michigan".scoreAgainst("HiMi") < "Hillsdale Michigan".scoreAgainst("Hillsd"))
        
        // Unicode supported
        XCTAssert("🐱".scoreAgainst("🐱") == 1)
        XCTAssert("🐱".scoreAgainst("🐼") == 0)
        XCTAssert("🐱🙃".scoreAgainst("🙃") == 0.15)
        XCTAssert("🐱🙃".scoreAgainst("🐱") == 0.75)
    }
}


extension Float
{
    func aboutEqual(b: Float, maxDiff: Float = 0.0001) -> Bool
    {
        return abs(self - b) < maxDiff
    }
}