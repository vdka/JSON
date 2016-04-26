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
    
    expect(true, toEqual: "true")
    expect(false, toEqual: "false")
    
    expect(.null, toEqual: "") // should be skipped by default
    expect(.null, options: [.noSkipNull], toEqual: "null")
    
  }
  
  func testSerializeObject() {
    
    expect([:], toEqual: "{}")
    expect(["key": 321], toEqual: "{\"key\":321}")
    expect(["key": 321, "key2": true], toEqual: "{\"key\":321,\"key2\":true}")
    
    // null stuff
    
    expect(["a": 1, "b": JSON.null, "c": 2], toEqual: "{\"a\":1,\"c\":2}")
    expect(["a": 1, "b": JSON.null, "c": 2], options: [.noSkipNull], toEqual: "{\"b\":null,\"a\":1,\"c\":2}")
    expect(["a": 1, "b": JSON.null, "c": 2], options: [.prettyPrint], toEqual: "{\n    \"a\": 1,\n    \"c\": 2\n}")
    expect(["a": 1, "b": JSON.null, "c": 2], options: [.prettyPrint, .noSkipNull], toEqual: "{\n    \"b\": null,\n    \"a\": 1,\n    \"c\": 2\n}")
    
    
    expect(["a": 1, "b": JSON.null, "c": 2, "d": JSON.null, "e": JSON.null], toEqual: "{\"a\":1,\"c\":2}")
    expect(["a": 1, "b": JSON.null, "c": 2, "d": JSON.null, "e": JSON.null], options: [.noSkipNull], toEqual: "{\"b\":null,\"e\":null,\"a\":1,\"d\":null,\"c\":2}")
  }
  
  func testSerializeArray() {
    expect([], toEqual: "[]")
    expect([1, 2, 3, 4], toEqual: "[1,2,3,4]")
    expect([true, false, "abc", 4, 5.0], toEqual: "[true,false,\"abc\",4,5.0]")
    
    // null stuff
    expect([1, JSON.null, 2], toEqual: "[1,2]")
    expect([1, JSON.null, 2], options: [.noSkipNull], toEqual: "[1,null,2]")
    expect([1, JSON.null, 2], options: [.prettyPrint], toEqual: "[\n    1,\n    2\n]")
    expect([1, JSON.null, 2], options: [.prettyPrint, .noSkipNull], toEqual: "[\n    1,\n    null,\n    2\n]")
    
    expect([1, JSON.null, JSON.null, 2, JSON.null], toEqual: "[1,2]")
    expect([1, JSON.null, JSON.null, 2, JSON.null], options: [.noSkipNull], toEqual: "[1,null,null,2,null]")
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
