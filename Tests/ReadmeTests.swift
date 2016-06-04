//
//  ReadmeTests.swift
//  JSON
//
//  Created by Ethan Jackwitz on 4/25/16.
//  Copyright © 2016 Ethan Jackwitz. All rights reserved.
//

import XCTest
import JSON

class ReadmeTests: XCTestCase {
  
  func testReadmeExample() { // Would be awkward if the readme examples didn't work.
    
    // assert possible
    _ = try! Money.decode(["minorUnits": 1000, "currency": "AUD"])
    _ = try! Money(json: ["minorUnits": 1000, "currency": "AUD"])
    
    [
      "name": "Harry",
      "age": 20,
      "accountBalances": [
        ["minorUnits": 10000, "currency": "AUD"] as JSON,
        ["minorUnits": 1000, "currency": "AUD"] as JSON,
        ["minorUnits": -20000, "currency": "AUD"] as JSON
      ] as JSON
    ] as JSON
    
    let savings = Money(minorUnits: 10000, currency: .AUD)
    let spending = Money(minorUnits: 1000, currency: .AUD)
    let studentLoans = Money(minorUnits: -20000, currency: .AUD)
    let person = Person(name: "Harry", age: 20, accountBalances: [spending, savings, studentLoans])
    
    try! print(person.serialized(options: [.prettyPrint]))
    
    // gross.
    let expectedOutput = "{\n    'name': 'Harry',\n    'age': 20,\n    'accountBalances': [\n        {\n            'minorUnits': 1000,\n            'currency': 'AUD'\n        },\n        {\n            'minorUnits': 10000,\n            'currency': 'AUD'\n        },\n        {\n            'minorUnits': -20000,\n            'currency': 'AUD'\n        }\n    ],\n    'totalBalance': {\n        'minorUnits': -9000,\n        'currency': 'AUD'\n    }\n}".substituting("'", for: "\"")
    
    // TODO (vdka): broken because we now have ordered dicts
    
    try! XCTAssertEqual(person.serialized(options: [.prettyPrint]), expectedOutput)
    
  }
  
}

enum Currency: String { case AUD }

struct Money {
  var minorUnits: Int
  var currency: Currency
}

func + (lhs: Money, rhs: Money) -> Money {
  guard lhs.currency == rhs.currency else { fatalError("Must be the same currency") }
  return Money(minorUnits: lhs.minorUnits + rhs.minorUnits, currency: rhs.currency)
}

struct Person {
  var name: String
  var age: Int
  var jobTitle: String?
  var accountBalances: [Money]
  var totalBalance: Money {
    return accountBalances.reduce(Money(minorUnits: 0, currency: .AUD), combine: +)
  }
  init(name: String, age: Int, jobTitle: String? = nil, accountBalances: [Money]) {
    self.name = name
    self.age = age
    self.jobTitle = jobTitle
    self.accountBalances = accountBalances
  }
}

extension Currency: JSONEncodable {}

extension Money: JSONEncodable {
  func encoded() -> JSON {
    return ["minorUnits": minorUnits, "currency": currency]
  }
}

extension Person: JSONEncodable {
  func encoded() -> JSON {
    return [
      "name": name,
      "age": age,
      "jobTitle": jobTitle.encoded(),
      "accountBalances": accountBalances.encoded(),
      "totalBalance": totalBalance
    ]
  }
}

extension Currency: JSONDecodable {}
extension Money: JSONDecodable {
  init(json: JSON) throws {
    let minorUnits = try json["minorUnits"].int ?? JSON.Error.BadField("minorUnits")
    let currency: Currency = try json.get("currency")
    self = Money(minorUnits: minorUnits, currency: currency)
  }
}

extension Person: JSONDecodable {
  init(json: JSON) throws {
    let name = try json["name"].string ?? JSON.Error.BadField("name")
    let age = try json["age"].int ?? JSON.Error.BadField("age")
    let accountBalances: [Money] = try json["accountBalances"].array?.flatMap(Money.init) ?? []
    self = Person(name: name, age: age, accountBalances: accountBalances)
  }
}
