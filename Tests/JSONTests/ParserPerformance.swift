
import XCTest
import JSON

fileprivate let n = 5

class ParserBenchmarks: XCTestCase {


  func testParseLargeJson() {

    let data = loadFixture("large")

    measure {
      for _ in 0..<n {
        _ = try! JSON.Parser.parse(data)
      }
    }
  }

  func testParseLargeMinJson() {

    let data = loadFixture("large_min")

    measure {
      for _ in 0..<n {
        _ = try! JSON.Parser.parse(data)
      }
    }
  }

  func testParseInsaneJson() {

    let data = loadFixture("insane")

    measure {
      _ = try! JSON.Parser.parse(data)
    }
  }

  func testParseLargeJsonToUsers() {

    let data = loadFixture("large")

    measure {
      for _ in 0..<n {

        let json = try! JSON.Parser.parse(data)

        guard case .array(let usersJson) = json else {
          XCTFail()
          return
        }

        _ = try! usersJson.map(User.init(json:))
      }
    }
  }

  // Foundation.JSONSerialization
  
  func testParseLargeJson_Foundation() {

    let data = loadFixtureData("large")

    measure {
      for _ in 0..<n {
        try! JSONSerialization.jsonObject(with: data, options: [])
      }
    }
  }

  func testParseLargeMinJson_Foundation() {

    let data = loadFixtureData("large_min")

    measure {
      for _ in 0..<n {
        try! JSONSerialization.jsonObject(with: data, options: [])
      }
    }
  }

  func testParseInsaneJson_Foundation() {

    let data = loadFixtureData("insane")

    measure {
      _ = try! JSONSerialization.jsonObject(with: data)
    }
  }

  func testParseLargeJsonToUsers_Foundation() {

    let data = loadFixtureData("large")

    measure {
      for _ in 0..<n {

        let json = try! JSONSerialization.jsonObject(with: data)

        guard let usersJson = json as? [Any] else {
          XCTFail()
          return
        }

        _ = try! usersJson.map(User.init(foundationJSON:))
      }
    }
  }

}

#if os(Linux)
extension ParserBenchmarks: XCTestCaseProvider {

  var allTests : [(String, () throws -> Void)] {
    return [
      ("testParseLargeJson", testParseLargeJson),
      ("testParseLargeMinJson", testParseLargeMinJson),
      ("testParseLargeJson_Foundation", testParseLargeJson_Foundation),
      ("testParseLargeMinJson_Foundation", testParseLargeMinJson_Foundation),
    ]
  }
}
#endif
