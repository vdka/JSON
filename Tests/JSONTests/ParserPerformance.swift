
import XCTest
import JSON

// TODO (vdka): determine why the first run of JSON.Parser.parse(_,_:) is so much slower
class ParserBenchmarks: XCTestCase {
  
  func testParseLargeJson() {

    let data = loadFixture("large")

    measure {
      _ = try! JSON.Parser.parse(data)
    }
  }

  func testParseLargeMinJson() {

    let data = loadFixture("large_min")

    measure {
      _ = try! JSON.Parser.parse(data)
    }
  }


  // Foundation.JSONSerialization
  
  func testParseLargeJson_Foundation() {

    let data = loadFixtureData("large")

    measure {
      try! JSONSerialization.jsonObject(with: data, options: [])
    }
  }

  func testParseLargeMinJson_Foundation() {

    let data = loadFixtureData("large_min")

    measure {
      try! JSONSerialization.jsonObject(with: data, options: [])
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

func urlForFixture(_ name: String) -> URL {

  let parent = (#file).components(separatedBy: "/").dropLast().joined(separator: "/")
  let url = URL(string: "file://\(parent)/Fixtures/\(name).json")!
  print("Loading fixture from url \(url)")
  return url
}

func loadFixture(_ name: String) -> [UInt8] {

  let url = urlForFixture(name)
  let data = Array(try! String(contentsOf: url).utf8)
  return data
}

func loadFixtureData(_ name: String) -> Foundation.Data {

  let url = urlForFixture(name)
  let data = try! Foundation.Data(contentsOf: url)
  return data
}
