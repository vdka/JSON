//
//  ParserTests.swift
//  JSON
//
//  Created by Ethan Jackwitz on 4/19/16.
//  Copyright © 2016 Ethan Jackwitz. All rights reserved.
//

import XCTest
@testable import JSON

class SerializerUnitTests: XCTestCase {
  
  func expect(input: JSON, options: [JSON.Serializer.Option] = [], toEqual expected: String, line: UInt = #line) {
    do {
      let output = try JSON.Serializer.serialize(input, options: options)
      XCTAssertEqual(expected, output, line: line)
    } catch {
      XCTFail("\(error)", line: line)
    }
  }

  func testSerializeNumber() {
    
    expect(1, toEqual: "1")
    expect(-1, toEqual: "-1")
    expect(0.1, toEqual: "0.1")
    expect(-0.1, toEqual: "-0.1")
    expect(1e100, toEqual: "1e+100")
    expect(-1e100, toEqual: "-1e+100")
    expect(123456.789, toEqual: "123456.789")
    expect(-123456.789, toEqual: "-123456.789")
    
  }

  func testSerializeString() {
    
    expect("", toEqual: surrounding(""))
    expect("🇦🇺", toEqual: surrounding("🇦🇺"))
    expect("vdka", toEqual: surrounding("vdka"))
    expect(" \\ ", toEqual: surrounding(" \\ "))
    expect("\\\"", toEqual: surrounding("\\\""))
    expect("\\\"\t\r\n\n", toEqual: surrounding("\\\"\t\r\n\n"))
    
  }

  func testSerializeValue() {
    
    expect(.null, toEqual: "") // should be skipped by default
    expect(true, toEqual: "true")
    expect(false, toEqual: "false")
    
  }
  
  func testSerializeObject() {
    
    expect([:], toEqual: "{}")
    expect(["key": 321], toEqual: "{\"key\":321}")
    expect(["key": 321, "key2": true], toEqual: "{\"key\":321,\"key2\":true}")
  }
  
  func testSerializeArray() {
    expect([], toEqual: "[]")
    expect([1, 2, 3, 4], toEqual: "[1,2,3,4]")
    expect([true, false, "abc", 4, 5.0], toEqual: "[true,false,\"abc\",4,5.0]")
  }
  
  func testPrettyPrinting() {
    expect([], options: [.prettyPrint], toEqual: "[]")
    expect([:], options: [.prettyPrint], toEqual: "{}")
    expect([1, 2], options: [.prettyPrint], toEqual: "[\n    1,\n    2\n]")
    expect([[1, 2] as JSON, [3, 4] as JSON], options: [.prettyPrint], toEqual: "[\n    [\n        1,\n        2\n    ],\n    [\n        3,\n        4\n    ]\n]")
    expect(["a": 1, "b": 2], options: [.prettyPrint], toEqual: "{\n    \"b\": 2,\n    \"a\": 1\n}") // NOTE: It is hard to account for dictionary ordering
    expect(["a": [1, 2] as JSON, "b": [3] as JSON], options: [.prettyPrint], toEqual: "{\n    \"b\": [\n        3\n    ],\n    \"a\": [\n        1,\n        2\n    ]\n}") // NOTE: It is hard to account for dictionary ordering
  }
}
