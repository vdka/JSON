

import XCTest
import Foundation
@testable import JSON

class ModelMappingTests: XCTestCase {

  let json: JSON = {
    let bytes = loadFixture("large")
    return try! JSON.Parser.parse(bytes)
  }()

  func testMapToModels() {

    guard let userJson = json.array?.first else {
      XCTFail()
      return
    }

    _ = try! User(json: userJson)
  }
  
}

#if os(Linux)
  extension JSONTests: XCTestCaseProvider {
    var allTests : [(String, () throws -> Void)] {
      return [
        ("testSerializeArray", testSerializeArray),
        ("testParse", testParse),
        ("testSanity", testSanity),
        ("testAccessors", testAccessors),
        ("testMutation", testMutation),
      ]
    }
  }
#endif

enum Currency: String { case AUD, EUR, GBP, USD }

struct Money {
  var minorUnits: Int
  var currency: Currency

}

struct Person {
  var name: String
  var age: Int
  var accountBalances: [Money]
  var petName: String?
}

extension Money: JSONConvertible {

  func encoded() -> JSON {
    return
      [
        "minorUnits": minorUnits,
        "currencyCode": currency.encoded()
    ]
  }

  init(json: JSON) throws {
    self.minorUnits = try json.get("minorUnits")
    self.currency   = try json.get("currencyCode")
  }
}


extension Person: JSONConvertible {

  func encoded() -> JSON {
    return
      [
        "name": name,
        "age": age,
        "accountBalances": accountBalances.encoded()
    ]
  }

  init(json: JSON) throws {
    self.name             = try json.get("name")
    self.age              = try json.get("age")
    self.accountBalances  = try json.get("accountBalances")
    self.petName          = try json.get("petName")
  }
}

