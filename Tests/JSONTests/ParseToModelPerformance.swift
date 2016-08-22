
import JSON

class ParseToModelBenchmarks: XCTestCase {

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
