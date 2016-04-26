
import XCTest
import PMJSON
import SwiftyJSON
import JASON
import JSON

class JSONBenchTests: XCTestCase {
  
  // Relies upon C stdlib
  
  func testParseVDKAJSON() {
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
