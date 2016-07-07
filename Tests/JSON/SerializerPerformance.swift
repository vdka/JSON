
import XCTest
import JSON

let largeJsonData = loadFixture("large")
let largeMinJsonData = loadFixture("large_min")
let largeJson = try! JSON.Parser.parse(largeJsonData)

class SerializerBenchmarks: XCTestCase {

  func testSerializerLargeJson() {
    measure {
      do {
        _ = try JSON.Serializer.serialize(largeJson)
      } catch {
        if let printableError = error as? CustomStringConvertible {
          XCTFail("JSON parse error: \(printableError)")
        }
      }
    }
  }
  
  func testSerializerLargeJsonPrettyPrinted() {
    measure {
      do {
        _ = try JSON.Serializer.serialize(largeJson, options: [.prettyPrint])
      } catch {
        if let printableError = error as? CustomStringConvertible {
          XCTFail("JSON parse error: \(printableError)")
        }
      }
    }
  }

  /*
  func testSerializerNSJSON() {
    let json = SwiftyJSON.JSON(jsonString)
    var s: String?
    measureBlock {
      s = json.rawString(options: [])!
    }
  }
 */
}
