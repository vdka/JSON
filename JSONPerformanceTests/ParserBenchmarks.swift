
import XCTest
import JSON

class ParserBenchmarks: XCTestCase {
  
  func testParseVDKAJSON() {
    // TODO (vdka): determine why the first run of JSON.Parser.parse(_,_:) is so much slower
    let data = Array(jsonString.nulTerminatedUTF8)
    _ = try! VDKAJSON.Parser.parse(data, options: [.noSkipNull])
    measure {
      _ = try! VDKAJSON.Parser.parse(data, options: [.noSkipNull])
    }
  }
  
  func testParseVDKAJSONTwitterData() {
    // TODO (vdka): determine why the first run of JSON.Parser.parse(_,_:) is so much slower
    let data = Array(twitterJsonString.nulTerminatedUTF8)
    _ = try! VDKAJSON.Parser.parse(data, options: [.noSkipNull])
    measure {
      for _ in 0...100 {
        _ = try! VDKAJSON.Parser.parse(data, options: [.noSkipNull])
      }
    }
  }
  
/*
  // NSJSONSerialization
  
  func testParseNSJSON() {
    let jsonData = jsonString.data(using: String.Encoding.utf8)!
    measure {
      try! JSONSerialization.jsonObject(with: jsonData, options: [])
    }
  }
  
  func testParseNSJSONTwitter() {
    let jsonData = twitterJsonString.data(using: String.Encoding.utf8)!
    measure {
      for _ in 0...100 {
        try! JSONSerialization.jsonObject(with: jsonData, options: [])
      }
    }
  }
*/
}
