

import XCTest
import Foundation
@testable import JSON

class AccessorTests: XCTestCase {

  let json: JSON =
    [
      "array": [1, 2, 3] as JSON,
      "object": ["Goodbye": "Brisbane", "Hello": "World"] as JSON,
      "intLiteral": 1,
      "intString": "1",
      "floatLiteral": 6.28,
      "floatString": "6.28",
      "string": "hello",
      "trueLiteral": true,
      "falseLiteral": false,
      "trueString": "true",
      "falseString": "false",
      "nullLiteral": JSON.null
    ]

  func testInts() {

    var value: Int
    do {

      value = try json.get("intLiteral")
      XCTAssert(value == 1)
      value = try json.get("intString")
      XCTAssert(value == 1)
    } catch {
      XCTFail("Failed to access a member: \(error)")
    }
  }

  func testFloatingPoints() {

    var value: Double
    do {

      value = try json.get("floatLiteral")
      XCTAssert(value == 6.28)
      value = try json.get("floatString")
      XCTAssert(value == 6.28)
    } catch {
      XCTFail("Failed to access a member: \(error)")
    }
  }

  func testBool() {

    var value: Bool
    do {

      value = try json.get("trueLiteral")
      XCTAssert(value == true)
      value = try json.get("trueString")
      XCTAssert(value == true)
      value = try json.get("falseLiteral")
      XCTAssert(value == false)
      value = try json.get("falseString")
      XCTAssert(value == false)
    } catch {
      XCTFail("Failed to access a member: \(error)")
    }
  }

  func testNull() {

    var value: Bool?
    do {

      value = try json.get("nullLiteral")
      XCTAssert(value == nil)
      value = try json.get("404 key not found")
      XCTAssert(value == nil)
    } catch {
      XCTFail("Failed to access a member: \(error)")
    }
  }

  func testDefaulting() {

    enum Color: String { case teal, unknown }

    let json: JSON = ["name": "Harry", "age": 38, "color": "teal"]

    do {
      var name: String

      name = try json.get("404", default: "vdka")
      XCTAssert(name == "vdka")

      name = try json.get("name", default: "Bob")
      XCTAssert(name == "Harry")

      name = try json.get("age", default: "Julia")
      XCTAssert(name == "Julia")

      var color: Color

      color = try json.get("color", default: Color.unknown)
      XCTAssert(color == .teal)

      color = try json.get("404", default: Color.unknown)
      XCTAssert(color == .unknown)

    } catch {
      XCTFail("An error occured: \(error)")
    }
  }

  func testIterator() {

    var values: [JSON] = []

    for value in json["array"]! {
      values.append(value)
    }
    XCTAssert(values == [1, 2, 3] as [JSON])
    values.removeAll()

    for value in json["object"]! {
      values.append(value)
    }
    XCTAssert(values == [["Hello": "World"], ["Goodbye": "Brisbane"]] as [JSON])
    values.removeAll()

    for value in json["intLiteral"]! {
      values.append(value)
    }
    XCTAssert(values == [1] as [JSON])
    values.removeAll()

    for value in json["nullLiteral"]! {
      values.append(value)
    }
    XCTAssert(values == [])
  }
}

#if os(Linux)
  extension JSONTests: XCTestCaseProvider {
    var allTests : [(String, () throws -> Void)] {
      return [
        ("testSerializeArray", testSerializeArray),
        ("testParse", testParse),
        ("testSanity", testSanity),
        ("testAccessors", testAccessors),
        ("testMutation", testMutation),
      ]
    }
  }
#endif
