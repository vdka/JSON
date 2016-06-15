
// MARK: - JSONDecodable

/// Conforming types can be decoded from a JSON instance
public protocol JSONDecodable {
  /// Initialize an instance of `Self` from JSON
  init(json: JSON) throws
}


// MARK: - Partial implementation

extension JSONDecodable {
  public static func decode(_ json: JSON) throws -> Self {
    return try Self(json: json)
  }
}


// MARK: - Bool Conformance to JSONDecodable

extension Bool: JSONDecodable {
  public init(json: JSON) throws {
    guard case .bool(let b) = json else { throw JSON.Error.badValue(json.value) }
    self = b
  }
}


// MARK: - String Conformance to JSONDecodable

extension String: JSONDecodable {
  public init(json: JSON) throws {
    guard case .string(let s) = json else { throw JSON.Error.badValue(json.value) }
    self = s
  }
}


// MARK: - FloatingPointTypes: JSONDecodable

extension Double: JSONDecodable {
  public init(json: JSON) throws {
    guard case .double(let d) = json else { throw JSON.Error.badValue(json.value) }
    self = d
  }
}

extension Float: JSONDecodable {
  public init(json: JSON) throws {
    guard case .double(let d) = json else { throw JSON.Error.badValue(json.value) }
    self = Float(d)
  }
}


// MARK: - IntegerTypes: JSONDecodable

extension Int: JSONDecodable {
  public init(json: JSON) throws {
    guard case .integer(let i) = json where Int64(Int.min) <= i && i <= Int64(Int.max) else { throw JSON.Error.badValue(json.value) }
    self = Int(i)
  }
}

extension Int64: JSONDecodable {
  public init(json: JSON) throws {
    guard case .integer(let i) = json else { throw JSON.Error.badValue(json.value) }
    self = i
  }
}


// NOTE: track rdar://23433955

// MARK: - Add decode to Optional JSONDecodables

// TODO (vdka): add init(json: JSON) throws
extension Optional where Wrapped: JSONDecodable {
  public init(json: JSON) throws {
    guard let value = json.value as? Wrapped else { throw JSON.Error.badValue(json.value) }
    self = value
  }
}


// MARK: - Add decode to RawRepresentable JSONDecodables

extension RawRepresentable where RawValue: JSONDecodable {
  public init(json: JSON) throws {
    guard let value = json.value as? RawValue else { throw JSON.Error.badValue(json.value) }
    self = try Self(rawValue: value) ?? JSON.Error.badValue(value)
  }
}


// MARK: - Add decode to Arrays of JSONDecodable

extension Array where Element: JSONDecodable {
  
  public init(json: JSON) throws {
    guard let array = json.array else { throw JSON.Error.badValue(json.value) }
    self = try array.map(Element.decode)
  }
}
