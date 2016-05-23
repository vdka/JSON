//
//  ParserTests.swift
//  JSON
//
//  Created by Ethan Jackwitz on 4/19/16.
//  Copyright © 2016 Ethan Jackwitz. All rights reserved.
//

import XCTest
@testable import JSON

func surrounding(string: String, by char: Character = "\"") -> String {
  return "\(char)\(string)\(char)"
}

func escaping(string: String) -> String {
  return string.stringByReplacingOccurrencesOfString("'", withString: "\"")
}

extension String {
  func substituting(this: String, for that: String) -> String {
    return self.stringByReplacingOccurrencesOfString(this, withString: that)
  }
}

class ParserUnitTests: XCTestCase {
  
  //TODO: add expect(_:, toThrow:_)
  
  func expect<T: Equatable>(input: String, toEqual expected: T, line: UInt = #line, afterApplying function: (inout JSON.Parser) -> () throws -> T) {
    var parser = JSON.Parser(string: input)
    do {
      let output = try function(&parser)()
      XCTAssertEqual(expected, output, line: line)
    } catch {
      XCTFail("\(error)", line: line)
    }
  }

  func testParseNumber() {
    
    expect("21", toEqual: 21, afterApplying: JSON.Parser.parseNumber)
    expect("1", toEqual: 1, afterApplying: JSON.Parser.parseNumber)
    expect("-1", toEqual: -1, afterApplying: JSON.Parser.parseNumber)
    expect("1e-1", toEqual: 0.1, afterApplying: JSON.Parser.parseNumber)
    expect("-1e-1", toEqual: -0.1, afterApplying: JSON.Parser.parseNumber)
    expect("-000000001", toEqual: -1, afterApplying: JSON.Parser.parseNumber)
    expect("-1e000000001", toEqual: -10.0, afterApplying: JSON.Parser.parseNumber)
    expect("12345.6789e01", toEqual: 123456.789, afterApplying: JSON.Parser.parseNumber)
    expect("-12345.6789e-01", toEqual: -1234.56789, afterApplying: JSON.Parser.parseNumber)
    
  }
  
  func testParseString() {
    
    expect(surrounding("🇦🇺"), toEqual: "🇦🇺", afterApplying: JSON.Parser.parseString)
    expect(surrounding("vdka"), toEqual: "vdka", afterApplying: JSON.Parser.parseString)
    expect(surrounding(""), toEqual: "", afterApplying: JSON.Parser.parseString)
    expect(surrounding(" \\ "), toEqual: " \\ ", afterApplying: JSON.Parser.parseString)
    expect(surrounding("\\\""), toEqual: "\\\"", afterApplying: JSON.Parser.parseString)
    expect(surrounding("\\\"\t\r\n\n"), toEqual: "\\\"\t\r\n\n", afterApplying: JSON.Parser.parseString)
    
  }
  
  func testParseValue() {
    
    expect("null", toEqual: JSON.null, afterApplying: JSON.Parser.parseValue)
    expect("true", toEqual: true, afterApplying: JSON.Parser.parseValue)
    expect("false", toEqual: false, afterApplying: JSON.Parser.parseValue)
    
  }
  
  func testParseObject() {
    
    expect("{}", toEqual: [:], afterApplying: JSON.Parser.parseObject)
    expect("{'key': 321}".substituting("'", for: "\""), toEqual: ["key": 321], afterApplying: JSON.Parser.parseObject)
    expect("{'key': 321, 'key2': true}".substituting("'", for: "\""), toEqual: ["key": 321, "key2": true], afterApplying: JSON.Parser.parseObject)
    expect("{ 'key' : 321 , 'key2' : true }".substituting("'", for: "\""), toEqual: ["key": 321, "key2": true], afterApplying: JSON.Parser.parseObject)
  }
  
  func testParseArray() {
    expect("[]", toEqual: [], afterApplying: JSON.Parser.parseArray)
    expect("[1, 2, 3, 4]", toEqual: [1, 2, 3, 4], afterApplying: JSON.Parser.parseArray)
    expect("[true, false, 'abc', 4, 5.0]".substituting("'", for: "\""), toEqual: [true, false, "abc", 4, 5.0], afterApplying: JSON.Parser.parseArray)
  }
  
//  func testSkipWhitespaceOneMillionTimes() {
//    var whiteSpace = ""
//    whiteSpace.unicodeScalars.reserveCapacity(100_000)
//    for _ in 0..<100_000 {
//      whiteSpace.unicodeScalars.append(" ")
//    }
//    
//    let parser = JSON.Parser(string: whiteSpace)
//    
//    measurePerformance {
//      parser.skipWhitespace()
//    }
//  }
}
