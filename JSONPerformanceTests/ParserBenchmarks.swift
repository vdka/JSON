
import XCTest
import PMJSON
import SwiftyJSON
import JASON
import JSON

class JSONBenchTests: XCTestCase {
  
  func testParseVDKAJSON() {
    // TODO (vdka): determine why the first run of JSON.Parser.parse(_,_:) is so much slower
    try! VDKAJSON.Parser.parse(jsonString, options: [.noSkipNull])
    measureBlock {
      try! VDKAJSON.Parser.parse(jsonString, options: [.noSkipNull])
    }
  }
  
  
  // Relies upon C stdlib
  
  func testParsePMJSON() {
    measureBlock {
      try! PMJSON.JSON.decode(jsonString)
    }
  }
  
  
  // NSJSONSerialization
  
  func testParseNSJSON() {
    let jsonData = jsonString.dataUsingEncoding(NSUTF8StringEncoding)!
    measureBlock {
      try! NSJSONSerialization.JSONObjectWithData(jsonData, options: [])
    }
  }
  
  func testParseSwiftyJSON() {
    let jsonData = jsonString.dataUsingEncoding(NSUTF8StringEncoding)!
    measureBlock {
      _ = SwiftyJSON.JSON(data: jsonData)
    }
  }
  
  func testParseJASON() {
    let jsonData = jsonString.dataUsingEncoding(NSUTF8StringEncoding)!
    measureBlock {
      _ = JASON.JSON(jsonData)
    }
  }
}
