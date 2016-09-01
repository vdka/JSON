
import XCTest
@testable import JSON

class SerializerTests: XCTestCase {

  func testBools() {

    expect(true, toSerializeTo: "true")
    expect(false, toSerializeTo: "false")
  }

  func testNull() {

    expect(.null, toSerializeTo: "null")
    expect(.null, toSerializeTo: "", withOptions: .omitNulls)
  }

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

  func testEscapeReverseSolidusString() {

    expect("\\", toSerializeTo: "'\\\\'")
  }

  func testEscapeQuoteString() {

    expect("\"", toSerializeTo: "'\\\"'")
  }

  func testFlagUnicodeString() {

    expect("🇦🇺", toSerializeTo: "'🇦🇺'")
  }

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

  func testObjectNullValue() {

    expect(["hello": JSON.null], toSerializeTo: "{'hello':null}")
  }

  func testObjectNullValueOmitNulls() {

    expect(["hello": JSON.null, "key": true], toSerializeTo: "{'key':true}", withOptions: .omitNulls)
  }

  func testObjectNullValueOmitNullsPretty() {

    expect(["hello": JSON.null, "key": true], toSerializeTo: "{\n    'key': true\n}", withOptions: [.omitNulls, .prettyPrint])
  }

  // NOTE(vdka): This isn't likely worth fixing.
  func testObjectSingleNullValueOmitNullsPretty() {

    expect(["key": JSON.null], toSerializeTo: "{\n\n}", withOptions: [.omitNulls, .prettyPrint])
  }

  func testEmptyArray() {

    expect([], toSerializeTo: "[]")
  }

  func testEmptyArrayPretty() {

    expect([], toSerializeTo: "[]", withOptions: .prettyPrint)
  }

  func testArrayNullValueOmitNulls() {

    expect([true, JSON.null, false], toSerializeTo: "[true,false]", withOptions: .omitNulls)
  }

  func testArraySingleNullValueOmitNulls() {

    expect([JSON.null], toSerializeTo: "[]", withOptions: .omitNulls)
  }

  func testArraySingleNullValueOmitNullsPretty() {

    expect([JSON.null], toSerializeTo: "[\n\n]", withOptions: [.omitNulls, .prettyPrint])
  }

  func testSingleElementArray() {

    expect(["value"], toSerializeTo: "['value']")
  }

  func testSingleElementArrayPretty() {

    expect(["value"], toSerializeTo: "[\n    'value'\n]", withOptions: .prettyPrint)
  }

  func testArrayNested() {

    expect([true, [false, [JSON.null] as JSON] as JSON], toSerializeTo: "[true,[false,[null]]]")
  }

  func testObjectNested() {

    expect(["a": ["b": ["c": true] as JSON] as JSON], toSerializeTo: "{'a':{'b':{'c':true}}}")
  }

  func testNestedObjectArray() {

    expect([["a": true] as JSON, ["b": [false] as JSON] as JSON], toSerializeTo: "[{'a':true},{'b':[false]}]")
  }

  func testEscapeControlString() {
    let pairs: [(String, String)] =
      [
        ("\u{00}", "'\\u0000'"),
        ("\u{01}", "'\\u0001'"),
        ("\u{02}", "'\\u0002'"),
        ("\u{03}", "'\\u0003'"),
        ("\u{04}", "'\\u0004'"),
        ("\u{05}", "'\\u0005'"),
        ("\u{06}", "'\\u0006'"),
        ("\u{07}", "'\\u0007'"),
        ("\u{08}",     "'\\b'"),
        ("\u{09}",     "'\\t'"),
        ("\u{0A}",     "'\\n'"),
        ("\u{0B}", "'\\u000B'"),
        ("\u{0C}",     "'\\f'"),
        ("\u{0D}",     "'\\r'"),
        ("\u{0E}", "'\\u000E'"),
        ("\u{0F}", "'\\u000F'"),
        ("\u{10}", "'\\u0010'"),
        ("\u{11}", "'\\u0011'"),
        ("\u{12}", "'\\u0012'"),
        ("\u{13}", "'\\u0013'"),
        ("\u{14}", "'\\u0014'"),
        ("\u{15}", "'\\u0015'"),
        ("\u{16}", "'\\u0016'"),
        ("\u{17}", "'\\u0017'"),
        ("\u{18}", "'\\u0018'"),
        ("\u{19}", "'\\u0019'"),
        ("\u{1A}", "'\\u001A'"),
        ("\u{1B}", "'\\u001B'"),
        ("\u{1C}", "'\\u001C'"),
        ("\u{1D}", "'\\u001D'"),
        ("\u{1E}", "'\\u001E'"),
        ("\u{1F}", "'\\u001F'")
    ]

    for (given, expected) in pairs {

      expect(given.encoded(), toSerializeTo: expected)
    }
  }
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
