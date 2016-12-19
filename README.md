# JSON

[![Language](https://img.shields.io/badge/Swift-3-brightgreen.svg)](http://swift.org) [![Build Status](https://travis-ci.org/vdka/JSON.svg?branch=master)](https://travis-ci.org/vdka/JSON)

Improve both the brevity and clarity of your model mapping code.

JSON provides a simple and performant interface for accessing and creating serialized data.

This library exposes an API with minimal surface area.

# API
<details>
  <summary>API summary</summary>
```swift
// Creating a JSON instance (static)
static func JSON.Parser.parse(_ buffer: UnsafeBufferPointer<UTF8.CodeUnit>, options: JSON.Parser.Option = []) throws -> JSON
static func JSON.Parser.parse(_ data: [UTF8.CodeUnit], options: JSON.Parser.Option = []) throws -> JSON
static func JSON.Parser.parse(_ data: Data, options: JSON.Parser.Option = []) throws -> JSON
static func JSON.Parser.parse(_ string: String, options: JSON.Parser.Option = []) throws -> JSON

// Serializing a JSON instance
static func JSON.Serializer.serialize(_ json: JSON, options: JSON.Serializer.Option = []) throws -> String
static func JSON.Serializer.serialize<O: TextOutputStream>(_ json: JSON, to stream: inout O, options: JSON.Serializer.Option) throws
func JSON.serialized(options: JSON.Serializer.Option = []) throws -> String

// Accessing JSON
func JSON.get<T: JSONInitializable>(_ field: String, `default`: String?) -> T
func JSON.get<T: JSONInitializable>(_ field: String, `default`: T? = nil) throws -> T?
func JSON.get<T: JSONInitializable>(_ field: String, `default`: [T]? = nil) throws -> [T]

var JSON.object: [String: JSON]?
var JSON.array: [JSON]?
var JSON.string: String?
var JSON.int: Int?
var JSON.bool: Bool?
var JSON.double: Double?

var JSON.isObject: Bool
var JSON.isArray: Bool
var JSON.isString: Bool
var JSON.isInt: Bool
var JSON.isBool: Bool
var JSON.isDouble: Bool

protocol JSONInitializable {
    init(json: JSON) throws
}

protocol JSONRepresentable {
    func encoded() -> JSON
}
```
</details>

For deserialization the `get` method is generic and initializes the result type with `init(json: JSON) throws` or throws an error indicative of what went wrong. Because this generic method is constraint to any type that conforms to `JSONInitializable` it is possible to extract your own complex nested models by just calling `get`.
Furthermore there are overloads to the `get` method that allow the initialization of `Optional` and `RawRepresentable` types when their `Wrapped` and `RawValue`s are conformant to `JSONInitialable`. This means the majority of your simple `RawRepresentable` enum's can be initialized without needing to create an explicit initializer.

Similarly on the model serialization side the `encoded` method is the single point of call. It is automatically called by the initializers for `ExpressibleByArrayLiteral` & `ExpressibleByDictionaryLiteral`. This makes declaring JSON instances extremely simple.

# Examples

[Samples](https://github.com/vdka/JSON-Sample) Catered examples using real API's
[Commandline application](https://github.com/vdka/cj) for accessing JSON when scripting

<details>
  <summary>Example Usage</summary>
```json
{
    "status": "online",
    "last_active": 1481873354,
    "email": "jane@example.com",
    "username": "janesmith",
    "name": "Jane Smith",
    "dob": 805852800,
    "accepted_terms": true
}
```

```swift
enum State: String { case online, offline }

struct User {
    var status:        Status
    var lastActive:    Date
    var name:          String
    var email:         String
    var dob:           Date
    var acceptedTerms: Bool
    var friends:       [String]
    var avatarUrl:     URL?
}

extension User: JSONInitializable {
    init(json: JSON) throws {
        status        = try json.get("status")
        lastActive    = try json.get("last_active")
        name          = try json.get("name")
        email         = try json.get("email")
        dob           = try json.get("dob")
        acceptedTerms = try json.get("accepted_terms")
        friends       = try json.get("friends")
        avatarUrl     = try json.get("avatar_url")
    }
}

extension User: JSONRepresentable {

    func encoded() -> JSON {
        return
            [
                "status": status,
                "name": name,
                "email": email,
                "dob": dob,
                "accepted_terms": acceptedTerms,
                "friends": friends.encoded(),
                "avatar_url": avatarUrl.encoded()
            ]
    }
}
```
</details>

# Installation

## CocoaPods
> Coming soon!

## Carthage
```
github "vdka/json"
```

## Swift Package Manager
```
.Package(url: "https://github.com/vdka/JSON", majorVersion: 0, minor: 16),
```
