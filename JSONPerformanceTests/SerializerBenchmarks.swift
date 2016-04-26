
import XCTest
import PMJSON
import SwiftyJSON
import JASON
import JSON

class SerializerBenchmarks: XCTestCase {
  
  func testSerializerVDKAJSON() {
    measureBlock {
      do {
        try VDKAJSON.Serializer.serialize(json)
      } catch {
        if let printableError = error as? CustomStringConvertible {
          XCTFail("JSON parse error: \(printableError)")
        }
      }
    }
  }
  
  func testSerializerVDKAJSONPrettyPrint() {
    measureBlock {
      do {
        try VDKAJSON.Serializer.serialize(json, options: [.prettyPrint])
      } catch {
        if let printableError = error as? CustomStringConvertible {
          XCTFail("JSON parse error: \(printableError)")
        }
      }
    }
  }
  
  func testSerializerPMJSON() {
    let json = try! PMJSON.JSON.decode(jsonString)
    measureBlock { 
      PMJSON.JSON.encodeAsString(json)
    }
  }
  
  func testSerializerPMJSONPrettyPrint() {
    let json = try! PMJSON.JSON.decode(jsonString)
    measureBlock { 
      PMJSON.JSON.encodeAsString(json, pretty: true)
    }
  }
  
  func testSerializerSwiftyJSON() {
    let json = SwiftyJSON.JSON(jsonString)
    var s: String?
    measureBlock {
      s = json.rawString(options: [])!
    }
    print(s!.characters.count)
  }
  
  func testSerializerNSJSON() {
    let json = SwiftyJSON.JSON(jsonString)
    var s: String?
    measureBlock {
      s = json.rawString(options: [])!
    }
  }
  
}
