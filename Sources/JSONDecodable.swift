
// MARK: - JSONDecodable

/// Conforming types can be decoded from a JSON instance
public protocol JSONDecodable {
  /// Initialize an instance of `Self` from JSON
  init(json: JSON) throws
  
  /// Return an instance of `Self` from JSON
  static func decode(json: JSON) throws -> Self
}


// MARK: - Partial implementation

extension JSONDecodable {
  public init(json: JSON) throws {
    self = try Self.decode(json)
  }
}


// MARK: - Bool Conformance to JSONDecodable

extension Bool: JSONDecodable {
  public static func decode(json: JSON) throws -> Bool {
    guard case .bool(let b) = json else { throw JSON.Error.BadValue(json.value) }
    return b
  }
}


// MARK: - String Conformance to JSONDecodable

extension String: JSONDecodable {
  public static func decode(json: JSON) throws -> String {
    guard case .string(let s) = json else { throw JSON.Error.BadValue(json.value) }
    return s
  }
}


// MARK: - FloatingPointTypes: JSONDecodable

extension Double: JSONDecodable {
  public static func decode(json: JSON) throws -> Double {
    guard case .double(let d) = json else { throw JSON.Error.BadValue(json.value) }
    return d
  }
}

extension Float: JSONDecodable {
  public static func decode(json: JSON) throws -> Float {
    guard case .double(let d) = json else { throw JSON.Error.BadValue(json.value) }
    return Float(d)
  }
}


// MARK: - IntegerTypes: JSONDecodable

extension Int: JSONDecodable {
  public static func decode(json: JSON) throws -> Int {
    guard case .integer(let i) = json where Int64(Int.min) <= i && i <= Int64(Int.max) else { throw JSON.Error.BadValue(json.value) }
    return Int(i)
  }
}

extension Int64: JSONDecodable {
  public static func decode(json: JSON) throws -> Int64 {
    guard case .integer(let i) = json else { throw JSON.Error.BadValue(json.value) }
    return i
  }
}


// NOTE: track rdar://23433955

// MARK: - Add decode to Optional JSONDecodables

extension Optional where Wrapped: JSONDecodable {
  public static func decode(json: JSON) throws -> Wrapped {
    guard let value = json.value as? Wrapped else { throw JSON.Error.BadValue(json.value) }
    return value
  }
}


// MARK: - Add decode to RawRepresentable JSONDecodables

extension RawRepresentable where RawValue: JSONDecodable {
  public static func decode(json: JSON) throws -> Self {
    guard let value = json.value as? RawValue else { throw JSON.Error.BadValue(json.value) }
    return try Self(rawValue: value) ?? JSON.Error.BadValue(value)
  }
}


// MARK: - Add decode to Arrays of JSONDecodable

extension Array where Element: JSONDecodable {
  public static func decode(json: JSON) throws -> [Element] {
    guard let array = json.array else { throw JSON.Error.BadValue(json.value) }
    return try array.map(Element.decode)
  }
  
  public init(json: JSON) throws {
    guard let array = json.array else { throw JSON.Error.BadValue(json.value) }
    self = try array.map(Element.decode)
  }
}
