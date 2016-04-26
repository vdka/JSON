
import XCTest
import JSON

let json: JSON = {
  print("Generating jsonString")
  
  let numElements = 100_000
  let arc4random_max: UInt64 = 0x100000000
  
  func randomNumber() -> Double { return Double(arc4random()) / Double(arc4random_max) }
  
  func randomName() -> String {
    var str = ""
    let chars = Array("abcdefghijklmnopqrstuvwxyz".characters)
    for _ in 0...5 {
      let char = chars[Int(arc4random_uniform(UInt32(chars.count)))]
      str.append(char)
    }
    str.appendContentsOf(" ")
    str.appendContentsOf(arc4random_uniform(10000).description)
    return str
  }
  
  var arr: [JSON] = []
  
  for _ in 0..<numElements {
    arr.append(
      [
        "x": randomNumber(),
        "y": randomNumber(),
        "z": randomNumber(),
        "name": randomName(),
        "opts": [
          "1": [1, true] as JSON
          ] as JSON
        ] as JSON
    )
  }
  print("Done generating jsonString")
  
  return ["coordinates": arr.encoded(), "info": "some info"]
}()

class JSONPerformanceTests: XCTestCase {
  
  
  override func setUp() {
    super.setUp()
    
    jsonString = try! JSON.Serializer.serialize(json)
    
    let jsonArray: JSON = .array((100_000..<200_000).map({ i in JSON(i) }))
    largeJsonArray = try! jsonArray.serialized()
  }
  
  var jsonString: String!
  var largeJsonArray: String!
  
  func testVDKAParsePerformanceWithLargeJson() { // VDKAParser
    
    measureBlock {
      do {
        try JSON.Parser.parse(self.jsonString)
      } catch {
        if let printableError = error as? CustomStringConvertible {
          XCTFail("JSON parse error: \(printableError)")
        }
      }
    }
  }
  
  func testParsePerformanceWithLargeJsonNSJSONSerialization() { // Apple
    
    let data = jsonString.dataUsingEncoding(NSUTF8StringEncoding)!
    
    measureBlock {
      do {
        try NSJSONSerialization.JSONObjectWithData(data, options: [])
      } catch {
        if let printableError = error as? CustomStringConvertible {
          XCTFail("JSON parse error: \(printableError)")
        }
      }
    }
  }
  
  func testSerializerSpeed() {
    measureBlock {
      do {
        try JSON.Serializer.serialize(json)
      } catch {
        if let printableError = error as? CustomStringConvertible {
          XCTFail("JSON parse error: \(printableError)")
        }
      }
    }
  }
  
  func testSerializerSpeedNSJSONSerialization() {
    let data = jsonString.dataUsingEncoding(NSUTF8StringEncoding)!
    let nsJson = try! NSJSONSerialization.JSONObjectWithData(data, options: [])
    measureBlock {
      do {
        try NSJSONSerialization.dataWithJSONObject(nsJson, options: [])
      } catch {
        if let printableError = error as? CustomStringConvertible {
          XCTFail("JSON parse error: \(printableError)")
        }
      }
    }
  }
  
  func testSerializerSpeedPrettyPrinting() {
    measureBlock {
      do {
        try JSON.Serializer.serialize(json, options: [.prettyPrint])
      } catch {
        if let printableError = error as? CustomStringConvertible {
          XCTFail("JSON parse error: \(printableError)")
        }
      }
    }
  }
  
  func testSerializerSpeedPrettyPrintingNSJSONSerialization() {
    let data = jsonString.dataUsingEncoding(NSUTF8StringEncoding)!
    let nsJson = try! NSJSONSerialization.JSONObjectWithData(data, options: [])
    measureBlock {
      do {
        try NSJSONSerialization.dataWithJSONObject(nsJson, options: [.PrettyPrinted])
      } catch {
        if let printableError = error as? CustomStringConvertible {
          XCTFail("JSON parse error: \(printableError)")
        }
      }
    }
  }
}