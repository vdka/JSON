

/// Conforming types can be decoded from a JSON instance
public protocol JSONInitializable {

  /// Initialize an instance of `Self` from JSON
  init(json: JSON) throws
}


// MARK: - Partial implementation

extension JSONInitializable {

  public static func decode(_ json: JSON) throws -> Self {
    return try Self(json: json)
  }
}


// MARK: - Bool Conformance to JSONInitializable

extension Bool: JSONInitializable {

  public init(json: JSON) throws {
    guard let b = json.bool else { throw JSON.Error.badValue(json) }
    self = b
  }
}


// MARK: - String Conformance to JSONInitializable

extension String: JSONInitializable {

  public init(json: JSON) throws {
    guard let s = json.string else { throw JSON.Error.badValue(json) }
    self = s
  }
}


// MARK: - FloatingPointTypes: JSONInitializable

extension Double: JSONInitializable {

  public init(json: JSON) throws {
    guard let d = json.double else { throw JSON.Error.badValue(json) }
    self = d
  }
}

extension Float: JSONInitializable {

  public init(json: JSON) throws {
    guard let f = json.float else { throw JSON.Error.badValue(json) }
    self = f
  }
}


// MARK: - IntegerTypes: JSONInitializable

extension Int: JSONInitializable {

  public init(json: JSON) throws {
    guard let i = json.int else { throw JSON.Error.badValue(json) }
    self = i
  }
}

extension Int64: JSONInitializable {

  public init(json: JSON) throws {
    guard let i = json.int64 else { throw JSON.Error.badValue(json) }
    self = i
  }
}


// NOTE: track rdar://23433955

// MARK: - Add decode to Optional JSONInitializables

// TODO (vdka): add init(json: JSON) throws
extension Optional where Wrapped: JSONInitializable {

  public init(json: JSON) throws {
    self = try Wrapped(json: json)
  }

  public static func decode(json: JSON) throws -> Optional<Wrapped> {
    return try Optional<Wrapped>(json: json)
  }
}


// MARK: - Add decode to RawRepresentable JSONInitializables

extension RawRepresentable where RawValue: JSONInitializable {

  public init(json: JSON) throws {
    guard let value = try Self(rawValue: RawValue(json: json)) else { throw JSON.Error.badValue(json) }
    self = value
  }

  public static func decode(json: JSON) throws -> Self {
    return try Self(json: json)
  }
}


// MARK: - Add decode to Arrays of JSONInitializable

extension Array where Element: JSONInitializable {

  public init(json: JSON) throws {
    guard let array = json.array else { throw JSON.Error.badValue(json) }
    self = try array.map(Element.init(json:))
  }

  public static func decode(json: JSON) throws -> [Element] {
    return try Array<Element>(json: json)
  }
}
