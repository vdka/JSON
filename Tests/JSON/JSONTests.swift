
import XCTest
@testable import JSON

class JSONTests: XCTestCase {
  
  func assertThrow(error: JSONParser.Error, json: String, line: UInt = #line) {
    do {
      try JSONParser.parse(json)
      XCTFail("Expected error, got success", line: line)
    } catch let err as JSONParser.Error {
      XCTAssertEqual(err, error, line: line)
    } catch {
      XCTFail(line: line)
    }
  }
  
  func assertThrow(error: JSONSerializer.Error, json: String, line: UInt = #line) {
    do {
      try JSONParser.parse(json)
      XCTFail("Expected error, got success", line: line)
    } catch let err as JSONSerializer.Error {
      XCTAssertEqual(err, error, line: line)
    } catch {
      XCTFail(line: line)
    }
  }
  
  func assertNoThrow(line: UInt = #line, closure: () throws -> Void) {
    do {
      try closure()
    } catch let error as CustomStringConvertible {
      XCTFail(error.description, line: line)
    } catch {
      XCTFail("Expected function not to throw")
    }
  }
  
  
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
    
    assertNoThrow {
      try JSONParser.parse("{\"name\":\"Harry\"}")
    }
    
    assertNoThrow {
      try JSONParser.parse("{\"name\":\"Harry\"}")
    }
    
    assertNoThrow { 
      try JSONParser.parse("{\n  \n}")
    }
    
    assertNoThrow { 
      try JSONParser.parse("{\"function\":null,\"numbers\":[4,8,15,16,23,42],\"y_index\":2,\"x_index\":12,\"z_index\":5,\"arcs\":[{\"p2\":[22.1,50],\"p1\":[10.5,15.5],\"radius\":5},{\"p2\":[23.1,40],\"p1\":[11.5,15.5],\"radius\":10},{\"p2\":[23.1,30],\"p1\":[12.5,15.5],\"radius\":3},{\"p2\":[24.1,20],\"p1\":[13.5,15.5],\"radius\":2},{\"p2\":[25.1,10],\"p1\":[14.5,15.5],\"radius\":8},{\"p2\":[26.1,0],\"p1\":[15.5,15.5],\"radius\":2}],\"label\":\"my label\"}")
    }
    
    assertNoThrow { 
      try JSONParser.parse("\"\\r\\n\\t\\\\/\"", options: [.allowFragments])
    }
//    
//    assertNoThrow { 
//      try JSONParser.parse("{\"name\":\"Harry\",\"role\":null}")
//    }
    
    XCTAssertEqual(try JSONParser.parse("{\"a\":\"1\",\"b\":null,\"c\":1}"), ["a": "1", "c": 1] as JSON)
    XCTAssertEqual(try JSONParser.parse("{\"a\":\"1\",\"b\":null,\"c\":1}", options: [.noSkipNull]), ["a": "1", "b": JSON.null, "c": 1] as JSON)
    
    XCTAssertEqual(try JSONParser.parse("[1, 2, null, 4, null, 6]"), [1, 2, 4, 6] as JSON)
    
  }
  
  func testSanity() {
    
    func assertSymmetricJSONConversion(json: JSON, options: [JSONSerializer.Option] = [], line: UInt = #line) {
      do {
        let json2 = try JSONParser.parse(json.serialized(options: options))
        XCTAssertEqual(json, json2, line: line)
      } catch let error as JSONParser.Error {
        XCTFail(error.description, line: line)
      } catch let error as JSONSerializer.Error {
        XCTFail(error.description, line: line)
      } catch {
        XCTFail(line: line)
      }
    }
    
    assertSymmetricJSONConversion([])
    assertSymmetricJSONConversion([], options: [.prettyPrint])
    assertSymmetricJSONConversion([:])
    assertSymmetricJSONConversion([:], options: [.prettyPrint])
    assertSymmetricJSONConversion(json)
    assertSymmetricJSONConversion(["symbols": "´ˆ¨®˚¬åß∂ƒ∆∫œ´∑˚®ƒ©∆ˆ¨¥∑´®∆∫∆åß∂ƒ√j˚˙Ω˙√ˆ∑ø®∆´˙ÒÚÔˆ¨ˆ¨Ó´"])
    assertSymmetricJSONConversion(["emojis": "👍🏽🍉🇦🇺"])
    assertSymmetricJSONConversion(["👍🏽", "🍉", "🇦🇺"])
    
  }
  
  func testPotential32BitError() {
    guard strideof(Int) == strideof(Int64) else { return }
    let json: JSON = ["min": Int64.min, "max": Int64.max]
    XCTAssertEqual(json["min"].int, Int(Int64.min))
    XCTAssertEqual((["num": Int.max] as JSON)["num"].int, Int.max)
  }
  
  func testAccessors() {
    struct Role: JSONDecodable {
      var title: String
      var time: Int
      private static func decode(json: JSON) throws -> Role {
        let title = try json["title"].string ?? raise(JSON.Error.BadField("title"))
        let time = try json["time"].int ?? raise(JSON.Error.BadField("time"))
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
