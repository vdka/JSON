
import XCTest
import Foundation
@testable import JSON

class JSONTests: XCTestCase {
  
  let json: JSON =
    [
      "name": "Bob", "age": 51, "nice": true, "hairy": false, "height": 182.43,
      "pets": ["Harry", "Peter"] as JSON,
      "roles": [
        ["title": "Developer", "timeSpent": 2] as JSON,
        ["title": "Student", "timeSpent": 3] as JSON
      ] as JSON
    ]
  
  func testSerializeArray() {
    try XCTAssertEqual(([1, 2, 3, 4, 5] as JSON).serialized(), "[1,2,3,4,5]")
  }
  
  func testParse() {
    
    XCTAssertEqual(try JSON.Parser.parse("[1, null, 3]"), [1, 3] as JSON)
    XCTAssertEqual(try JSON.Parser.parse("[1, null, 3]", options: [.noSkipNull]), [1, JSON.null, 3] as JSON)
    XCTAssertEqual(try JSON.Parser.parse("{\"a\":\"1\",\"b\":null,\"c\":1}"), ["a": "1", "c": 1] as JSON)
    XCTAssertEqual(try JSON.Parser.parse("{\"a\":\"1\",\"b\":null,\"c\":1}", options: [.noSkipNull]), ["a": "1", "b": JSON.null, "c": 1] as JSON)
    
  }
  
  func testSanity() {
    
    func assertSymmetricJSONConversion(json: JSON, options: [JSON.Serializer.Option] = [], line: UInt = #line) {
      do {
        let json2 = try JSON.Parser.parse(json.serialized(options: options))
        XCTAssertEqual(json, json2, line: line)
      } catch {
        XCTFail(line: line)
      }
    }
    
    assertSymmetricJSONConversion([1, [2, 3] as JSON])

    assertSymmetricJSONConversion([1, 25])
    assertSymmetricJSONConversion(["key": "value", "key2": 2]) // TODO: Investigate
    
    assertSymmetricJSONConversion([])
    assertSymmetricJSONConversion([], options: [.prettyPrint])
    assertSymmetricJSONConversion([:])
    assertSymmetricJSONConversion([:], options: [.prettyPrint])
    assertSymmetricJSONConversion([[:] as JSON, [:] as JSON])
    
    assertSymmetricJSONConversion(json)
    assertSymmetricJSONConversion(["symbols": "œ∑´®†¥¨ˆøπ“‘«åß∂ƒ©˙∆˚¬…æΩ≈ç√∫˜µ≤≥÷Œ„´‰ˇÁ¨ˆØ∏”’»ÅÍÎÏ˝ÓÔÒÚÆ¸˛Ç◊ı˜Â¯˘¿"])
    assertSymmetricJSONConversion(["emojis": "👍🏽🍉🇦🇺"])
    assertSymmetricJSONConversion(["👍🏽", "🍉", "🇦🇺"])
    
  }
  
  func testAccessors() {
    struct Role: JSONDecodable {
      var title: String
      var time: Int
      private static func decode(json: JSON) throws -> Role {
        let title = try json["title"].string ?? JSON.Error.BadField("title")
        let time = try json["time"].int ?? JSON.Error.BadField("time")
        return Role(title: title, time: time)
      }
    }
    
    XCTAssertEqual(json["name"].string, "Bob")
    XCTAssertEqual(json["age"].int, 51)
    XCTAssertEqual(json["nice"].bool, true)
    XCTAssertEqual(json["hairy"].bool, false)
    XCTAssertEqual(json["height"].double, 182.43)
    XCTAssertEqual(json["pets"].array?.flatMap({ $0.string }) ?? [], ["Harry", "Peter"])
    XCTAssertEqual(json["pets"][0].string, "Harry")
    XCTAssertEqual(json["pets"][1].string, "Peter")
    XCTAssertEqual(json["roles"][0]["title"].string, "Developer")
    XCTAssertEqual(json["roles"][0]["timeSpent"].int, 2)
    XCTAssertEqual(json["roles"][1]["title"].string, "Student")
    XCTAssertEqual(json["roles"][1]["timeSpent"].int, 3)
    XCTAssertEqual(json["roles"][0].object!, ["title": .string("Developer"), "timeSpent": .integer(2)])
    XCTAssertEqual(json["roles"][1].object!, ["title": .string("Student"), "timeSpent": .integer(3)])
    
    XCTAssertEqual(json["name"].int, nil)
    XCTAssertEqual(json["name"].bool, nil)
    XCTAssertEqual(json["name"].int64, nil)
    XCTAssertEqual(json["name"].double, nil)
    XCTAssertEqual(json["roles"][1000], nil)
    XCTAssertEqual(json[0], nil)
  }
  
  func testMutation() {
    var json: JSON = ["height": 1.90, "array": [1, 2, 3] as JSON]
    XCTAssertEqual(json["height"].double, 1.90)
    json["height"] = 1.91
    XCTAssertEqual(json["height"].double, 1.91)
    
    XCTAssertEqual(json["array"][0], 1)
    json["array"][0] = 4
    XCTAssertEqual(json["array"][0], 4)
  }
}

#if os(Linux)
  extension JSONTests: XCTestCaseProvider {
    var allTests : [(String, () throws -> Void)] {
      return [
        ("testSanity", testSanity),
        ("testAccessors", testAccessors),
        ("testMutation", testMutation),
        ("testPotential32BitError", testPotential32BitError)
      ]
    }
  }
#endif
