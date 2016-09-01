
import XCTest
@testable import JSON

class SerializerTests: XCTestCase {

  func testSerializeNumber() {

    expect(1, toSerializeTo: "1")
    expect(-1, toSerializeTo: "-1")
    expect(0.1, toSerializeTo: "0.1")
    expect(-0.1, toSerializeTo: "-0.1")
    expect(1e100, toSerializeTo: "1e+100")
    expect(-1e100, toSerializeTo: "-1e+100")
    expect(123456.789, toSerializeTo: "123456.789")
    expect(-123456.789, toSerializeTo: "-123456.789")

  }

  func testEmptyString() {

    expect("", toSerializeTo: "''")
  }

  func testSimpleString() {

    expect("simple", toSerializeTo: "'simple'")
  }

  func testEscapeSolidusString() {

    expect("/", toSerializeTo: "'/'")
  }

  func testEscapeReverseSolidusString() {

    expect("\\", toSerializeTo: "'\\\\'")
  }

  func testEscapeBackspaceString() {

    expect("\u{0008}", toSerializeTo: "'\\b'")
  }

  func testEscapeControlString() {

    for value in (0...0x1F) {

      guard ![0x08, 0x0C, 0x0A, 0x0D, 0x09].contains(value) else { continue }
      let desiredString = "\\u" + UnicodeScalar(value)!.description.padding(toLength: 4, withPad: "0", startingAt: 0)
      expect(String(UnicodeScalar(value)!).encoded(), toSerializeTo: desiredString)
    }

//    expect("\u{0000}", toSerializeTo: "'\\u0000'")
  }

  func testEscapeTabString() {

    expect("\t", toSerializeTo: "'\\t'")
  }

  func testEscapeNewlineString() {

    expect("\n", toSerializeTo: "'\\n'")
  }

  func testEscapeFormfeedString() {

    expect("\u{000C}", toSerializeTo: "'\\f'")
  }

  func testEscapeCarriageReturnString() {

    expect("\r", toSerializeTo: "'\\r'")
  }

  func testEscapeQuoteString() {
    expect("\"", toSerializeTo: "'\\\"'")
  }

  func testFlagUnicodeString() {

    expect("🇦🇺", toSerializeTo: "'🇦🇺'")
  }

  /*
  func testSerializeValue() {

    expect(true, toSerializeTo: "true")
    expect(false, toSerializeTo: "false")

    expect(.null, toSerializeTo: "") // should be skipped by default
    expect(.null, options: [.noSkipNull], toSerializeTo: "null")

  }

  func testSerializeObject() {

    expect([:], toSerializeTo: "{}")
    expect(["key": 321], toSerializeTo: "{'key':321}".substituting("'", for: "\""))
    expect(["key": 321, "key2": true], toSerializeTo: "{'key':321,'key2':true}".substituting("'", for: "\""))

    // null stuff

    expect(["a": 1, "b": JSON.null, "c": 2], toSerializeTo: "{'a':1,'c':2}".substituting("'", for: "\""))
    expect(["a": 1, "b": JSON.null, "c": 2], options: [.noSkipNull], toSerializeTo: "{'a':1,'b':null,'c':2}".substituting("'", for: "\""))
    expect(["a": 1, "b": JSON.null, "c": 2], options: [.prettyPrint], toSerializeTo: "{\n    'a': 1,\n    'c': 2\n}".substituting("'", for: "\""))
    expect(["a": 1, "b": JSON.null, "c": 2], options: [.prettyPrint, .noSkipNull], toSerializeTo: "{\n    'a': 1,\n    'b': null,\n    'c': 2\n}".substituting("'", for: "\""))


    expect(["a": 1, "b": JSON.null, "c": 2, "d": JSON.null, "e": JSON.null], toSerializeTo: "{'a':1,'c':2}".substituting("'", for: "\""))
    expect(["a": 1, "b": JSON.null, "c": 2, "d": JSON.null, "e": JSON.null], options: [.noSkipNull], toSerializeTo: "{'a':1,'b':null,'c':2,'d':null,'e':null}".substituting("'", for: "\""))
  }

  func testSerializeArray() {
    expect([], toSerializeTo: "[]")
    expect([1, 2, 3, 4], toSerializeTo: "[1,2,3,4]")
    expect([true, false, "abc", 4, 5.0], toSerializeTo: "[true,false,'abc',4,5.0]".substituting("'", for: "\""))

    // null stuff
    expect([1, JSON.null, 2], toSerializeTo: "[1,2]")
    expect([1, JSON.null, 2], options: [.noSkipNull], toSerializeTo: "[1,null,2]")
    expect([1, JSON.null, 2], options: [.prettyPrint], toSerializeTo: "[\n    1,\n    2\n]")
    expect([1, JSON.null, 2], options: [.prettyPrint, .noSkipNull], toSerializeTo: "[\n    1,\n    null,\n    2\n]")

    expect([1, JSON.null, JSON.null, 2, JSON.null], toSerializeTo: "[1,2]")
    expect([1, JSON.null, JSON.null, 2, JSON.null], options: [.noSkipNull], toSerializeTo: "[1,null,null,2,null]")
  }
  */

  func testEmptyObject() {

    expect([:], toSerializeTo: "{}")
  }

  func testEmptyObjectPretty() {

    expect([:], toSerializeTo: "{}", withOptions: .prettyPrint)
  }

  func testSinglePairObject() {
    expect(["key": "value"], toSerializeTo: "{'key':'value'}")
  }

  func testSinglePairObjectPretty() {
    expect(["key": "value"], toSerializeTo: "{\n    'key': 'value'\n}", withOptions: .prettyPrint)
  }

  func testEmptyArray() {

    expect([], toSerializeTo: "[]")
  }

  func testEmptyArrayPretty() {

    expect([], toSerializeTo: "[]", withOptions: .prettyPrint)
  }

  func testSingleElementArray() {
    expect(["value"], toSerializeTo: "['value']")
  }

  func testSingleElementArrayPretty() {
    expect(["value"], toSerializeTo: "[\n    'value'\n]", withOptions: .prettyPrint)
  }

//  func testPrettyPrinting() {
//    expect([], toSerializeTo: "[]", withOptions: .prettyPrint)
//    expect([:], toSerializeTo: "{}", withOptions: .prettyPrint)
//    expect([1, 2], options: [.prettyPrint], toSerializeTo: "[\n    1,\n    2\n]")
//    expect([[1, 2] as JSON, [3, 4] as JSON], options: [.prettyPrint], toSerializeTo: "[\n    [\n        1,\n        2\n    ],\n    [\n        3,\n        4\n    ]\n]")
//    expect(["a": 1, "b": 2], options: [.prettyPrint], toSerializeTo: "{\n    'a': 1,\n    'b': 2\n}".substituting("'", for: "\""))
//    expect(["a": [1, 2] as JSON, "b": [3] as JSON], options: [.prettyPrint], toSerializeTo: "{\n    'a': [\n        1,\n        2\n    ],\n    'b': [\n        3\n    ]\n}".substituting("'", for: "\""))
//  }
}

extension SerializerTests {

  func expect(_ input: JSON, toSerializeTo expected: String, withOptions options: JSON.Serializer.Option = [],
              file: StaticString = #file, line: UInt = #line) {

    let expected = expected.replacingOccurrences(of: "'", with: "\"")

    do {

      let result = try JSON.Serializer.serialize(input, options: options)
      XCTAssertEqual(result, expected, file: file, line: line)
    } catch {
      XCTFail("\(error)", file: file, line: line)
    }
  }

  func expect(_ input: JSON, toThrow expectedError: JSON.Serializer.Error, withOptions options: JSON.Serializer.Option = [],
              file: StaticString = #file, line: UInt = #line) {

    do {

      _ = try JSON.Serializer.serialize(input, options: options)
    } catch let error as JSON.Serializer.Error {

      XCTAssertEqual(error, expectedError, file: file, line: line)
    } catch {

      XCTFail("expected to throw \(expectedError) but got a different error type!.")
    }
  }
}
