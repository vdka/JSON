# JSON

This library makes dealing with JSON feel more _native_ to Swift.

Internally JSON is represented as follows in a simple `enum`. This means there is no
`Any` type used internally for storage. Each _element_ of the JSON is stored as its Swift native type.

```swift
/// Any value that can be expressed in JSON has a representation in `JSON`.
public enum JSON {
  case object([String: JSON])
  case array([JSON])
  case null
  case bool(Bool)
  case string(String)
  case integer(Int64)
  case double(Double)
}
```

A long example:

```swift
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
  var accountsBalances: [Money]
  var totalBalance: Money {
    return accountsBalances.reduce(Money(minorUnits: 0, currency: .AUD), combine: +)
  }
}
```

## Encoding

```swift
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
      "accountBalances": accountsBalances.encoded(),
      "totalBalance": totalBalance
    ]
  }
}

let savings = Money(minorUnits: 10000, currency: .AUD)
let spending = Money(minorUnits: 1000, currency: .AUD)
let studentLoans = Money(minorUnits: -20000, currency: .AUD)
let person = Person(name: "Harry", age: 20, accountsBalances: [spending, savings, studentLoans])

print(try! JSONSerializer.serialize(person, options: [.prettyPrint]))
```

```json
{
  "totalBalance": {
    "currency": "AUD",
    "minorUnits": -9000
  },
  "age": 20,
  "accountBalances": [
    {
      "currency": "AUD",
      "minorUnits": 1000
    },
    {
      "currency": "AUD",
      "minorUnits": 10000
    },
    {
      "currency": "AUD",
      "minorUnits": -20000
    }
  ],
  "name": "Harry"
}
```

## Decoding

```swift
extension Currency: JSONDecodable {} // RawRepresentable types have a default implementation. You must still conform though.
extension Money: JSONDecodable {
  static func decode(json: JSON) throws -> Money {
    let minorUnits = try json["minorUnits"].int ?? raise(JSON.Error.BadField("minorUnits"))
    let currency: Currency = try json.get("currency")
    return Money(minorUnits: minorUnits, currency: currency)
  }
}

extension Person: JSONDecodable {
  static func decode(json: JSON) throws -> Person {
    let name = try json["name"].string ?? raise(JSON.Error.BadField("name"))
    let age = try json["age"].int ?? raise(JSON.Error.BadField("age"))
    let accountBalances: [Money] = try json["accountBalances"].array?.flatMap(Money.init) ?? []
    return Person(name: name, age: age, accountBalances: accountBalances)
  }
}

try Money.decode(["minorUnits": 1000, "currency": "AUD"])
try Money(json: ["minorUnits": 1000, "currency": "AUD"])

let personJson: JSON = [
  "name": "Harry",
  "age": 20,
  "accountBalances": [
    ["minorUnits": 10000, "currency": "AUD"] as JSON,
    ["minorUnits": 1000, "currency": "AUD"] as JSON,
    ["minorUnits": -20000, "currency": "AUD"] as JSON
  ] as JSON
]

print(try Person.decode(personJson))
```

```swift
Person(name: "Harry", age: 20, accountBalances: [Money(minorUnits: 10000, currency: Currency.AUD), Money(minorUnits: 1000, currency: Currency.AUD), Money(minorUnits: -20000, currency: Currency.AUD)])
```

# Components

## JSONEncodable
```swift
public protocol JSONEncodable {
  /// Returns a `JSON` representation of `self`
  func encoded() -> JSON
}
```

In order to initialize a JSON instance from a literal it must conform to JSONEncodable.
This is because `encoded` is called internally during conversion from these
literal types.

```swift
extension JSON: DictionaryLiteralConvertible {
  public init(dictionaryLiteral elements: (String, JSONEncodable)...) {
    var dict: [String: JSON] = [:]
    for (k, v) in elements {
      dict[k] = v.encoded()
    }

    self = .object(dict)
  }
}
```

## Parser
```swift
JSONParser.parse(string: String) throws -> JSON
```
Throws `iff` JSON does not conform to [RFC7159](https://tools.ietf.org/html/rfc7159) compatible JSON.

## Serializer
```swift
JSONSerializer.serialize(json: JSON, options: [JSONSerializer.Option] = []) throws -> String
```
Throws `iff` Double values are non finite.

# Language Limitations
- Protocol extensions cannot have add conformance to other protocols [radar](http://www.openradar.me/23433955)
- Concrete type extensions cannot add conformance and have a where clause
- Concrete type extensions with associated value cannot be constrained to concrete types

# Inspired By
- [colindrake.me](http://colindrake.me/2015/10/28/implementing-a-small-dsl-in-swift/)
  + This post inspired a second look at representing structured String data as Swift enums.
- [JSONCore](https://github.com/tyrone-sudeium/JSONCore)
  + The Parser and Serializer are both taken from here. The idea of JSON as an enum too.
- [SwiftJSON](https://github.com/SwiftyJSON/SwiftyJSON)
  + Access style draws inspiration from here. `json["name"].string`
