
// MARK: - JSON Accessors

extension JSON {
  /// The raw value associated with this JSON
  public var value: Any? {
    switch self {
    case .array(let a): return a
    case .object(let o): return o
      
    case .null: return nil
    case .bool(let b): return b
    case .string(let s): return s
    case .double(let d): return d
    case .integer(let i): return Int(i)
    }
  }
  
  /// Returns the content matching the type of its destination
  public func get<T: JSONDecodable>(_ field: String) throws -> T {
    guard let json = self[field] else { throw JSON.Error.badField(field) }
    
    return try T.decode(json)
  }
  
  /// Returns the content matching the type of its destination
  public func get<T: RawRepresentable>(_ field: String) throws -> T {
    guard let rawValue = self[field]?.value as? T.RawValue else { throw JSON.Error.badField(field) }
    guard let value = T(rawValue: rawValue) else { throw JSON.Error.badValue(rawValue) }
    
    return value
  }
  
  /// Returns the content matching the type of its destination
  public func get<T: protocol<RawRepresentable, JSONDecodable>>(_ field: String) throws -> T {
    guard let json = self[field] else { throw JSON.Error.badField(field) }
    
    return try T.decode(json)
  }
}


// MARK: - JSON Subscripts

// TODO: Investigate `subscript(set key: String) -> JSONEncodable?` for setting.
extension JSON {
  /// Treat this JSON as a JSON object and attempt to get or set its associated Dictionary values.
  public subscript(key: String) -> JSON? {
    get {
      // TODO (vdka): Without lazy dictionaries it may be quicker to iterate over the array for accesses. O(n)
      
      guard case .object(let o) = self else { return nil }
      
      var dict: [String: JSON] = [:]
      for (k, v) in o {
        dict[k] = v
      }
      
      return dict[key]
      
      // TODO (vdka): This should be possible but causes a compiler seg fault.
//      return object?[key] 
    }
    
    set {
      guard case .object(var o) = self else { return }
      defer { self = .object(o) }
      for (i, (k, _)) in o.enumerated() where key == k {
        switch newValue {
        case let newValue?:
          o[i] = (k, newValue)
          
        case nil:
          o.remove(at: i)
          
        }
        return
      }
      
      guard let newValue = newValue else { return }
      o.append( (key, newValue) )
      self = .object(o)
    }
  }
  
  /**
   Treat this JSON as a JSON array and attempt to get or set its
   associated Array values.
   This will do nothing if you attempt to set outside of bounds.
   */
  public subscript(index: Int) -> JSON? {
    get {
      guard case .array(let a) = self where a.indices ~= index else { return nil }
      return a[index]
    }
    
    // TODO: Testing for nested objects
    set {
      guard case .array(var a) = self where a.indices ~= index else { return }
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
    
    var dict: [String: JSON] = [:]
    for (k, v) in o {
      dict[k] = v
    }
    
    return dict
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
    guard case .integer(let i) = self else { return nil }
    return i
  }
  
  /// Returns this enum's associated Bool value iff `self == .bool(_)`, `nil` otherwise.
  public var bool: Bool? {
    guard case .bool(let b) = self else { return nil }
    return b
  }
  
  /// Returns this enum's associated Double value iff `self == .double(_)`, `nil` otherwise.
  public var double: Double? {
    guard case .double(let d) = self else { return nil }
    return d
  }
}


// MARK: Non RFC JSON types

extension JSON {
  
  /// Returns this enum's associated `Int64` value as an `Int` iff `self == .integer(_)`, `nil` otherwise.
  public var int: Int? {
    // where clause protects against RunTime crashes where the value of i won't fit within a native Int
    guard case .integer(let i) = self where Int64(Int.min) <= i && i <= Int64(Int.max) else { return nil }
    return Int(i)
  }
  
  /// Returns this enum's associated `Double` value as an `Float` iff `self == .double(_)`, `nil` otherwise.
  public var float: Float? {
    guard case .double(let d) = self else { return nil }
    return Float(d)
  }
}


// MARK: JSON Accessors calling into Element.decode(json: JSON)

extension JSON {
  
  /// Calls `try? T.decode(self)`
  func typed<T: JSONDecodable>() -> T? {
    return try? T.decode(self)
  }
}
