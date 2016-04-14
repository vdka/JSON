
// MARK: - JSONEncodable

/// Used to declare that that a type can be represented as JSON
public protocol JSONEncodable {
  
  /* NOTE: This should be a throwing method. As if any of JSONEncodable's fields are FloatingPoint.NaN or .infinity they
   cannot be represented as valid RFC conforming JSON.
   
     This isn't currently throwing because it is called by `*literalType` initializers in order to convert
   [JSONEncodable] & [String: JSONEncodable]
  */
  
  /// Returns a `JSON` representation of `self`
  func encoded() -> JSON
}


// MARK: - JSON Conformance to JSONEncodable

//// NOTE: Is this necessary?
extension JSON: JSONEncodable {
  public init(_ value: JSONEncodable) {
    self = value.encoded()
  }
  
  public func encoded() -> JSON {
    return self
  }
}


// NOTE: track rdar://23433955


// MARK: - Add encoded to Optional JSONEncodables

extension Optional where Wrapped: JSONEncodable {
  public func encoded() -> JSON {
    guard let `self` = self  else { return JSON.null }
    return JSON(self)
  }
}


// MARK: - Add encoded to RawRepresentable JSONEncodables

extension RawRepresentable where RawValue: JSONEncodable {
  public func encoded() -> JSON {
    return JSON(rawValue)
  }
}


// MARK: - Add encoded to Collections of JSONEncodable

extension CollectionType where Generator.Element: JSONEncodable {
  public func encoded() -> JSON {
    return .array(self.map({ $0.encoded() }))
  }
}


// MARK: - Bool Conformance to JSONEncodable

extension Bool: JSONEncodable {
  public func encoded() -> JSON {
    return .bool(self)
  }
}


// MARK: - String Conformance to JSONEncodable

extension String: JSONEncodable {
  public func encoded() -> JSON {
    return .string(self)
  }
}


// MARK: - FloatingPointTypes: JSONEncodable

extension Double: JSONEncodable {
  public func encoded() -> JSON {
    return .double(self)
  }
}

extension Float: JSONEncodable {
  public func encoded() -> JSON {
    return .double(Double(self))
  }
}


// MARK: - IntegerTypes: JSONEncodable

// NOTE: This sucks. It is very repetitive and ugly, is there a possiblity of `extension IntegerType: JSONEncodable` in the future?
extension Int: JSONEncodable {
  public func encoded() -> JSON {
    return .integer(Int64(self))
  }
}

extension UInt8: JSONEncodable {
  public func encoded() -> JSON {
    return .integer(Int64(self))
  }
}

extension UInt16: JSONEncodable {
  public func encoded() -> JSON {
    return .integer(Int64(self))
  }
}

extension UInt32: JSONEncodable {
  public func encoded() -> JSON {
    return .integer(Int64(self))
  }
}

extension Int8: JSONEncodable {
  public func encoded() -> JSON {
    return .integer(Int64(self))
  }
}

extension Int16: JSONEncodable {
  public func encoded() -> JSON {
    return .integer(Int64(self))
  }
}

extension Int32: JSONEncodable {
  public func encoded() -> JSON {
    return .integer(Int64(self))
  }
}

extension Int64: JSONEncodable {
  public func encoded() -> JSON {
    return .integer(self)
  }
}
