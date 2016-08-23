
import XCTest
import JSONCore

let largeJsonData = loadFixture("large")
let largeJsonFoundationData = loadFixtureData("large")

let largeJson = try! JSON.Parser.parse(largeJsonData)

class SerializerBenchmarks: XCTestCase {

  override func setUp() {
    super.setUp()
    do {
      _ = try JSON.Serializer.serialize(largeJson)
    } catch {}
  }

  func testSerializerPerformance() {

    measure {
      do {
        _ = try JSON.Serializer.serialize(largeJson)
      } catch { XCTFail() }
    }
  }

  func testSerializerPrettyPrintedPerformance() {

    measure {
      do {
        _ = try JSON.Serializer.serialize(largeJson, options: [.prettyPrint])
      } catch { XCTFail() }
    }
  }

  func testSerializerFoundationPerformance() {

    let nsJson = try! JSONSerialization.jsonObject(with: largeJsonFoundationData, options: [])

    measure {
      do {
        try JSONSerialization.data(withJSONObject: nsJson, options: [])
      } catch { XCTFail() }
    }
  }

  func testSerializerFoundationPrettyPrintedPerformance() {

    let nsJson = try! JSONSerialization.jsonObject(with: largeJsonFoundationData, options: [])

    measure {
      do {
        try JSONSerialization.data(withJSONObject: nsJson, options: .prettyPrinted)
      } catch { XCTFail() }
    }
  }
}
