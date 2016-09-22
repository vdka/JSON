# JSON

[![Language](https://img.shields.io/badge/Swift-3-brightgreen.svg)](http://swift.org)

This is Not just Another Swift JSON Package. This is _**the**_ Swift JSON Package.
When you are transforming directly to models this framework is [faster](https://github.com/vdka/JSONBenchmarks) than `Foundation.JSONSerialization`.

Time to Parse and initialize a struct from a sample 432KB JSON file.

|          | Foundation | vdka/json |
|:---------|-----------:|----------:|
| **Time** | `149.7ms`  | `27.03ms` |
| **LOC**  | `71`       | `35`      |

Tests run on Darwin (Linux Foundation is even slower) built with `-Ounchecked`

Type safety can get you a long way, lets see how you can use it for your applications.

```swift
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
```

