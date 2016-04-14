
import XCTest
@testable import JSON

class JSONPerformanceTests: XCTestCase {
  
  
  override func setUp() {
    super.setUp()
    
    json = {
      print("Generating jsonString")
      
      let numElements = 10_000
      let arc4random_max = 0x100000000
      
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
    
    jsonString = try! JSONSerializer.serialize(json)
    
    let jsonArray: JSON = .array((100_000..<200_000).map({ i in JSON(i) }))
    largeJsonArray = try! jsonArray.serialized()
  }
  
  var json: JSON!
  var jsonString: String!
  var largeJsonArray: String!
  
  func testParsePerformanceWithLargeJson() {
    
    measureBlock {
      do {
        self.json = try JSONParser.parse(self.jsonString)
      } catch {
        if let printableError = error as? CustomStringConvertible {
          XCTFail("JSON parse error: \(printableError)")
        }
      }
    }
  }
  
  func testParsePerformanceWithLargeJsonNSJSONSerialization() {
    
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
  
  func testParseSimple10KeyPairObject() {
    let tenKeyJson = try! ([
      "abcde": 1,
      "yerea": "ueiro",
      "leida": false,
      "iweur": true,
      "cnale": 9324,
      "awier": 839.4,
      "weiru": -1.0,
      "eiruaa": "12311238jf",
      "ljasdflkj": true,
      "ewkrjl": "qelrkjl"
    ] as JSON).serialized()
    
    measureBlock {
      do {
        for _ in 0..<10000 {
          try JSONParser.parse(tenKeyJson)
        }
      } catch {
        if let printableError = error as? CustomStringConvertible {
          XCTFail("JSON parse error: \(printableError)")
        }
      }
    }
  }
  
  func testParseLargeJsonArray() {
    measureBlock {
      do {
        try JSONSerializer.serialize(self.largeJsonArray!)
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
        try JSONSerializer.serialize(self.json!)
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
        try JSONSerializer.serialize(self.json!, options: [.prettyPrint])
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