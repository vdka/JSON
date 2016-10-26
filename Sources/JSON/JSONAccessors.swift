

extension JSON {

  public func get<T: JSONInitializable>() throws -> T {
    return try T(json: self)
  }

  /// - Note: This call will throw iff the initializer does.
  public func get<T: JSONInitializable>() throws -> T? {
    if case .null = self { return nil }
    return try T(json: self)
  }

  public func get<T: JSONInitializable>() throws -> [T] {
    guard case .array(let array) = self else { throw JSON.Error.badValue(self) }

    return try array.map(T.init(json:))
  }

  public func get<T: RawRepresentable>() throws -> T
    where T.RawValue: JSONInitializable
  {
    return try T(json: self)
  }

  public func get<T: RawRepresentable>() throws -> T?
    where T.RawValue: JSONInitializable
  {
    if case .null = self { return nil }
    return try T(json: self)
  }

  public func get<T: RawRepresentable>() throws -> [T]
    where T.RawValue: JSONInitializable
  {
    guard case .array(let array) = self else { throw JSON.Error.badValue(self) }

    return try array.map(T.init(json:))
  }

  public func get<T: RawRepresentable & JSONInitializable>() throws -> T {

    return try T(json: self)
  }


  public func get<T: RawRepresentable & JSONInitializable>() throws -> T?
    where T.RawValue: JSONInitializable
  {
    if case .null = self { return nil }
    return try T(json: self)
  }

  /// Returns the content matching the type of its destination
  public func get<T: RawRepresentable & JSONInitializable>() throws -> [T] {
    guard case .array(let array) = self else { throw JSON.Error.badValue(self) }

    return try array.map(T.init(json:))
  }
}


extension JSON {

  public func get(field: String) throws -> JSON {
    guard let json = self[field] else { throw JSON.Error.badField(field) }
    return json
  }

  /// Returns the content matching the type of its destination
  public func get<T: JSONInitializable>(_ field: String) throws -> T {
    guard let json = self[field] else { throw JSON.Error.badField(field) }

    return try T(json: json)
  }

  /// If the Field exists in the JSON then this will call to the expected types initializer
  /// - Note: This call will throw iff the initializer does
  public func get<T: JSONInitializable>(_ field: String) throws -> T? {
    guard let json = self[field] else { return nil }
    if case .null = json { return nil }
    return try T(json: json)
  }

  public func get<T: JSONInitializable>(_ field: String) throws -> [T] {
    guard let array = self[field].array else { throw JSON.Error.badField(field) }

    return try array.map(T.init(json:))
  }

  /// Returns the content matching the type of its destination
  public func get<T: RawRepresentable>(_ field: String) throws -> T
    where T.RawValue: JSONInitializable
  {
    let rawValue: T.RawValue = try self.get(field)
    guard let value = T(rawValue: rawValue) else { throw JSON.Error.badField(field) }

    return value
  }

  /// Returns the content matching the type of its destination
  public func get<T: RawRepresentable>(_ field: String) throws -> [T]
    where T.RawValue: JSONInitializable
  {
    guard let array = self[field].array else { throw JSON.Error.badField(field) }

    return try array.map(T.init(json:))
  }

  // NOTE: This is the most constrained version therefore the compiler should use this in the case of a RawRepresentable & JSONInitializable

  /// Returns the content matching the type of its destination
  public func get<T: RawRepresentable & JSONInitializable>(_ field: String) throws -> T {
    guard let json = self[field] else { throw JSON.Error.badField(field) }

    return try T(json: json)
  }

  /// Returns the content matching the type of its destination
  public func get<T: RawRepresentable & JSONInitializable>(_ field: String) throws -> [T] {
    guard let array = self[field].array else { throw JSON.Error.badField(field) }

    return try array.map(T.init(json:))
  }
}


// MARK: - JSON Subscripts

// TODO: Investigate `subscript(set key: String) -> JSONRepresentable?` for setting.
extension JSON {
  /// Treat this JSON as a JSON object and attempt to get or set its associated Dictionary values.
  public subscript(key: String) -> JSON? {
    get {
      guard case .object(let object) = self else { return nil }

      return object[key]
    }

    set {
      guard case .object(var object) = self else { return }

      object[key] = newValue
      self = .object(object)
    }
  }

  /**
   Treat this JSON as a JSON array and attempt to get or set its
   associated Array values.
   This will do nothing if you attempt to set outside of bounds.
   */
  public subscript(index: Int) -> JSON? {
    get {
      guard case .array(let a) = self, a.indices ~= index else { return nil }
      return a[index]
    }

    // TODO: Testing for nested objects
    set {
      guard case .array(var a) = self, a.indices ~= index else { return }
      switch newValue {
      case .some(let newValue):
        a[index] = newValue

      case .none:
        a.remove(at: index)
      }
      self = .array(a)
    }
  }
}


// MARK: - JSON Accessors

extension JSON {

  /// Returns this enum's associated Dictionary value iff `self == .object(_), `nil` otherwise.
  public var object: [String: JSON]? {
    guard case .object(let o) = self else { return nil }

    return o
  }
}

extension JSON {

  /// Returns this enum's associated Array value iff `self == .array(_)`, `nil` otherwise.
  public var array: [JSON]? {
    guard case .array(let a) = self else { return nil }
    return a
  }

  /// Returns this enum's associated String value iff `self == .string(_)`, `nil` otherwise.
  public var string: String? {
    guard case .string(let s) = self else { return nil }
    return s
  }

  /// Returns this enum's associated `Int64` value iff `self == .integer(i)`, `nil` otherwise.
  public var int64: Int64? {
    switch self {
    case .integer(let i): return i
    case .string(let s): return Int64(s)
    default: return nil
    }
  }

  /// Returns this enum's associated Bool value iff `self == .bool(_)`, `nil` otherwise.
  public var bool: Bool? {
    switch self {
    case .bool(let b): return b
    case .string(let s): return Bool(s)
    default: return nil
    }
  }

  /// Returns this enum's associated Double value iff `self == .double(_)`, `nil` otherwise.
  public var double: Double? {

    switch self {
    case .double(let d): return d
    case .string(let s): return Double(s)
    case .integer(let i): return Double(i)
    default: return nil
    }
  }
}


// MARK: Non RFC JSON types

extension JSON {

  /// Returns this enum's associated `Int64` value as an `Int` iff `self == .integer(_)`, `nil` otherwise.
  public var int: Int? {
    switch self {
    case .integer(let i): return Int(exactly: i)
    case .string(let s): return Int(s)
    default: return nil
    }
  }

  /// Returns this enum's associated `Double` value as an `Float` iff `self == .double(_)`, `nil` otherwise.
  public var float: Float? {

    switch self {
    case .double(let d): return Float(d)
    case .string(let s): return Float(s)
    case .integer(let i): return Float(i)
    default: return nil
    }
  }
}
