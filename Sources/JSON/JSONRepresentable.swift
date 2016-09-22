

/// Used to declare that that a type can be represented as JSON
public protocol JSONRepresentable {

  /* NOTE: This should be a throwing method. As if any of JSONRepresentable's fields are FloatingPoint.NaN or .infinity they
   cannot be represented as valid RFC conforming JSON.

     This isn't currently throwing because it is called by `*literalType` initializers in order to convert
   [JSONRepresentable] & [String: JSONRepresentable]
  */

  /// Returns a `JSON` representation of `self`
  func encoded() -> JSON
}


// MARK: - JSON Conformance to JSONRepresentable

extension JSON: JSONRepresentable {

  public init(_ value: JSONRepresentable) {
    self = value.encoded()
  }
}


// MARK: - Add `serialized` to `JSONRepresentable`

extension JSONRepresentable {

  public func serialized(options: JSON.Serializer.Option = []) throws -> String {
    return try JSON.Serializer.serialize(self.encoded(), options: options)
  }
}


// NOTE: track http://www.openradar.me/23433955


// MARK: - Add encoded to Optional JSONRepresentables

extension Optional where Wrapped: JSONRepresentable {
  public func encoded() -> JSON {
    guard let `self` = self  else { return JSON.null }
    return JSON(self)
  }
}


// MARK: - Add encoded to RawRepresentable JSONRepresentables

extension RawRepresentable where RawValue: JSONRepresentable {

  public func encoded() -> JSON {
    return JSON(rawValue)
  }
}


// MARK: - Add encoded to Sequences of JSONRepresentable

extension Sequence where Iterator.Element: JSONRepresentable {

  public func encoded() -> JSON {
    return .array(self.map({ $0.encoded() }))
  }
}

// MARK: - Add encoded to Sequences of [String: JSONRepresentable]

extension Sequence where Iterator.Element == (key: String, value: JSONRepresentable) {
  
  public func encoded() -> JSON {
    var encoded: [String: JSON] = [:]
    for (key, value) in self {
      encoded[key] = value.encoded()
    }
    return .object(encoded)
  }
}


// MARK: - Bool Conformance to JSONRepresentable

extension Bool: JSONRepresentable {

  public func encoded() -> JSON {
    return .bool(self)
  }
}


// MARK: - String Conformance to JSONRepresentable

extension String: JSONRepresentable {

  public func encoded() -> JSON {
    return .string(self)
  }
}


// MARK: - FloatingPointTypes: JSONRepresentable

extension Double: JSONRepresentable {

  public func encoded() -> JSON {
    return .double(self)
  }
}

extension Float: JSONRepresentable {

  public func encoded() -> JSON {
    return .double(Double(self))
  }
}


// MARK: - IntegerTypes: JSONRepresentable

// NOTE: This sucks. It is very repetitive and ugly, is there a possiblity of `extension IntegerType: JSONRepresentable` in the future?
extension Int: JSONRepresentable {

  public func encoded() -> JSON {
    return .integer(Int64(self))
  }
}

extension UInt8: JSONRepresentable {

  public func encoded() -> JSON {
    return .integer(Int64(self))
  }
}

extension UInt16: JSONRepresentable {

  public func encoded() -> JSON {
    return .integer(Int64(self))
  }
}

extension UInt32: JSONRepresentable {

  public func encoded() -> JSON {
    return .integer(Int64(self))
  }
}

extension Int8: JSONRepresentable {

  public func encoded() -> JSON {
    return .integer(Int64(self))
  }
}

extension Int16: JSONRepresentable {

  public func encoded() -> JSON {
    return .integer(Int64(self))
  }
}

extension Int32: JSONRepresentable {

  public func encoded() -> JSON {
    return .integer(Int64(self))
  }
}

extension Int64: JSONRepresentable {

  public func encoded() -> JSON {
    return .integer(self)
  }
}
