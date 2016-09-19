

/// WARNING: Internal type. Used to constrain an extension on Optional to be sudo non Generic.
public protocol _JSON {}
extension JSON: _JSON {}

// Would be best if we could constrain extensions to be Non-Generic. Swift3?
// TODO: Test setters ensure behaviour is predictable and expected when operating on nested JSON
// TODO: Check if it is viable to use JSONRepresentable as the contraint and be rid of _JSON
extension Optional where Wrapped: _JSON {

  /// returns the `JSON` value for key iff `Wrapped == JSON.object(_)` and there is a value for the key
  /// - Note: you will get better performance if you chain your subscript eg. ["key"]?.string This is because the compiler will retain more type information.
  public subscript(key: String) -> JSON? {
    get {
      return object?[key]
    }

    set {
      guard var json = self as? JSON else { return }
      guard case .object(_) = json else { return }
      json[key] = newValue
      self = json as? Wrapped
    }
  }

  /// returns the JSON value at index iff `Wrapped == JSON.array(_)` and the index is within the arrays bounds
  public subscript(index: Int) -> JSON? {
    get {
      guard let `self` = self as? JSON else { return nil }
      guard case .array(let a) = self, a.indices ~= index else { return nil }
      return a[index]
    }

    set {
      guard var a = (self as? JSON)?.array else { return }
      switch newValue {
      case .none: a.remove(at: index)
      case .some(let value):
        a[index] = value
        self = (JSON.array(a) as? Wrapped)
      }

    }
  }
}


// MARK: - Standard typed accessors

extension Optional where Wrapped: _JSON {

  /// Returns an array of `JSON` iff `Wrapped == JSON.array(_)`
  public var array: [JSON]? {
    guard let `self` = self as? JSON else { return nil }
    return self.array
  }

  /// Returns a `JSON` object iff `Wrapped == JSON.object(_)`
  public var object: [String: JSON]? {
    guard let `self` = self as? JSON else { return nil }
    return self.object
  }

  /// Returns a `String` iff `Wrapped == JSON.string(_)`
  public var string: String? {
    guard let `self` = self as? JSON else { return nil }
    return self.string
  }

  /// Returns this enum's associated `Int64` iff `self == .integer(_)`, `nil` otherwise.
  public var int64: Int64? {
    guard let `self` = self as? JSON else { return nil }
    return self.int64
  }

  /// Returns a `Bool` iff `Wrapped == JSON.bool(_)`
  public var bool: Bool? {
    guard let `self` = self as? JSON else { return nil }
    return self.bool
  }

  /// Returns a `Double` iff `Wrapped == JSON.double(_)`
  public var double: Double? {
    guard let `self` = self as? JSON else { return nil }
    return self.double
  }
}


// MARK: Non RFC JSON types

extension Optional where Wrapped: _JSON {

  /// Returns an `Int` iff `Wrapped == JSON.integer(_)`
  public var int: Int? {
    guard let `self` = self as? JSON else { return nil }
    return self.int
  }

  /// Returns an `Float` iff `Wrapped == JSON.double(_)`
  public var float: Float? {
    guard let `self` = self as? JSON else { return nil }
    return self.float
  }
}
