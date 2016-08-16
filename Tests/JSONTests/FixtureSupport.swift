
import Foundation

public func urlForFixture(_ name: String) -> URL {

  let parent = (#file).components(separatedBy: "/").dropLast().joined(separator: "/")
  let url = URL(string: "file://\(parent)/Fixtures/\(name).json")!
  print("Loading fixture from url \(url)")
  return url
}

public func loadFixture(_ name: String) -> [UInt8] {

  let url = urlForFixture(name)
  let data = Array(try! String(contentsOf: url).utf8)
  return data
}

public func loadFixtureData(_ name: String) -> Foundation.Data {

  let url = urlForFixture(name)
  let data = try! Foundation.Data(contentsOf: url)
  return data
}
