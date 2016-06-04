
import XCTest
import PMJSON
import SwiftyJSON
import JASON
import JSON

class ParserBenchmarks: XCTestCase {
  
  func testParseVDKAJSON() {
    // TODO (vdka): determine why the first run of JSON.Parser.parse(_,_:) is so much slower
    let data = Array(jsonString.nulTerminatedUTF8)
    try! VDKAJSON.Parser.parse(data, options: [.noSkipNull])
    measureBlock {
      try! VDKAJSON.Parser.parse(data, options: [.noSkipNull])
    }
  }
  
  func testParseVDKAJSONTwitterData() {
    // TODO (vdka): determine why the first run of JSON.Parser.parse(_,_:) is so much slower
    let data = Array(twitterJsonString.nulTerminatedUTF8)
    try! VDKAJSON.Parser.parse(data, options: [.noSkipNull])
    measureBlock {
      for _ in 0...100 {
        try! VDKAJSON.Parser.parse(data, options: [.noSkipNull])
      }
    }
  }
  
  // NSJSONSerialization
  
  func testParseNSJSON() {
    let jsonData = jsonString.dataUsingEncoding(NSUTF8StringEncoding)!
    measureBlock {
      try! NSJSONSerialization.JSONObjectWithData(jsonData, options: [])
    }
  }
  
  func testParseNSJSONTwitter() {
    let jsonData = twitterJsonString.dataUsingEncoding(NSUTF8StringEncoding)!
    measureBlock {
      for _ in 0...100 {
        try! NSJSONSerialization.JSONObjectWithData(jsonData, options: [])
      }
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
  
  // Relies upon C stdlib
  
  func testParsePMJSON() {
    measureBlock {
      try! PMJSON.JSON.decode(jsonString)
    }
  }
  
}
