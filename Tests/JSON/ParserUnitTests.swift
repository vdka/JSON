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
    var data = Array(input.nulTerminatedUTF8)
    data.withUnsafeMutableBufferPointer { bufferPointer in
      var parser = JSON.Parser.init(bufferPointer: bufferPointer, options: [])
  //    var parser = JSON.Parser.init(data: input.utf8.map({ $0 }))
      do {
        let output = try function(&parser)()
        XCTAssertEqual(expected, output, line: line)
      } catch {
        XCTFail("\(error)", line: line)
      }
    }
  }

  func testParseNumber() {
    
    
    // Simple tests
    expect("1", toEqual: 1, afterApplying: JSON.Parser.parseNumber)
    expect("21", toEqual: 21, afterApplying: JSON.Parser.parseNumber)
    expect("321", toEqual: 321, afterApplying: JSON.Parser.parseNumber)
    
    // Simple negative tests
    
    expect("-1", toEqual: -1, afterApplying: JSON.Parser.parseNumber)
    expect("-21", toEqual: -21, afterApplying: JSON.Parser.parseNumber)
    expect("-321", toEqual: -321, afterApplying: JSON.Parser.parseNumber)
    
    // Exponent tests
    
    expect("1e-1", toEqual: 0.1, afterApplying: JSON.Parser.parseNumber)
    expect("-1e-1", toEqual: -0.1, afterApplying: JSON.Parser.parseNumber)
    expect("12.34e01", toEqual: 123.4, afterApplying: JSON.Parser.parseNumber)
    expect("12.34e-01", toEqual: 1.234, afterApplying: JSON.Parser.parseNumber)
    expect("12345.6789e01", toEqual: 123456.789, afterApplying: JSON.Parser.parseNumber)
    expect("-12345.6789e-01", toEqual: -1234.56789, afterApplying: JSON.Parser.parseNumber)
    
    // Special exponent case (base x 10 ^ exponent) = (base{e|E}exponent) = base
    
    expect("12.34e0", toEqual: 12.34, afterApplying: JSON.Parser.parseNumber)
    expect("12.34e-0", toEqual: 12.34, afterApplying: JSON.Parser.parseNumber)
    
    // Test leading 0's
    
    expect("00000001", toEqual: 1, afterApplying: JSON.Parser.parseNumber)
    expect("-0000001", toEqual: -1, afterApplying: JSON.Parser.parseNumber)
    
    // Test int64 boundaries
    
    expect("9223372036854775807", toEqual: 9223372036854775807, afterApplying: JSON.Parser.parseNumber)
    expect("-9223372036854775808", toEqual: -9223372036854775808, afterApplying: JSON.Parser.parseNumber)
    
    // Test decimal precision
    
    expect("0.0000000000000000001", toEqual: 0.0000000000000000001, afterApplying: JSON.Parser.parseNumber)
    
    // Test against a Swift bug found where switch statements with `where` clauses were having the where clause seemingly _ignored_?
    // only occured when trailed by a non null character for some reason.
    
    expect("182.43,", toEqual: 182.43, afterApplying: JSON.Parser.parseNumber)
    
  }
  
  func testParseString() {
    
    expect(surrounding(""), toEqual: "", afterApplying: JSON.Parser.parseString)
    expect(surrounding("vdka"), toEqual: "vdka", afterApplying: JSON.Parser.parseString)
    expect(surrounding(" \\\\ "), toEqual: " \\ ", afterApplying: JSON.Parser.parseString)
    expect(surrounding("\\\""), toEqual: "\"", afterApplying: JSON.Parser.parseString)
    expect(surrounding("\\\"\\t\\r\\n"), toEqual: "\"\t\r\n", afterApplying: JSON.Parser.parseString)
    
    expect(surrounding("🇦🇺"), toEqual: "🇦🇺", afterApplying: JSON.Parser.parseString)
    
  }
  
  func testParseLiterals() {
    
    expect("null", toEqual: JSON.null, afterApplying: JSON.Parser.parseValue)
    expect("true", toEqual: true, afterApplying: JSON.Parser.parseValue)
    expect("false", toEqual: false, afterApplying: JSON.Parser.parseValue)
    
  }
  
  func testParseObject() {
    
    expect("{}", toEqual: [:], afterApplying: JSON.Parser.parseObject)
    expect(" {} ", toEqual: [:], afterApplying: JSON.Parser.parseObject)
    expect("{'key': 321}".substituting("'", for: "\""), toEqual: ["key": 321], afterApplying: JSON.Parser.parseObject)
    expect("{'key': 321, 'key2': true}".substituting("'", for: "\""), toEqual: ["key": 321, "key2": true], afterApplying: JSON.Parser.parseObject)
    expect("{ 'key' : 321 , 'key2' : true }".substituting("'", for: "\""), toEqual: ["key": 321, "key2": true], afterApplying: JSON.Parser.parseObject)
    
    expect("{'a': 1, 'b': {'c': 2}}".substituting("'", for: "\""), toEqual: ["a": 1, "b": ["c": 2] as JSON], afterApplying: JSON.Parser.parseObject)
  }
  
  func testParseArray() {
    expect("[]", toEqual: [], afterApplying: JSON.Parser.parseArray)
    expect("[1, [2, 3]]", toEqual: [1, [2, 3] as JSON], afterApplying: JSON.Parser.parseArray)
    expect("[1, 2, 3, 4]", toEqual: [1, 2, 3, 4], afterApplying: JSON.Parser.parseArray)
    expect("[true, false, 'abc', 4, 5.0]".substituting("'", for: "\""), toEqual: [true, false, "abc", 4, 5.0], afterApplying: JSON.Parser.parseArray)
  }
  
  func testParseValue() {
    expect("[true, false, 'abc', 4, 5.0]".substituting("'", for: "\""), toEqual: [true, false, "abc", 4, 5.0], afterApplying: JSON.Parser.parseValue)
  }
  
  // MARK: - Test potentially troubling values
  func testTroublingValues() {
    expect("{'Приве́т नमस्ते שָׁלוֹם':true}".substituting("'", for: "\""), toEqual: ["Приве́т नमस्ते שָׁלוֹם": true], afterApplying: JSON.Parser.parseValue)
    expect(surrounding("سمَـَّوُوُحخ ̷̴̐خ ̷̴̐خ ̷̴̐خ امارتيخ ̷̴̐خ"), toEqual: "سمَـَّوُوُحخ ̷̴̐خ ̷̴̐خ ̷̴̐خ امارتيخ ̷̴̐خ", afterApplying: JSON.Parser.parseString)
  }
}
