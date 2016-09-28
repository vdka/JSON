

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


// MARK: - JSON Equatable conformance

extension JSON: Equatable {}
public func ==(lhs: JSON, rhs: JSON) -> Bool {
  switch (lhs, rhs) {
  case (.object(let l), .object(let r)): return l == r
  case (.array(let l), .array(let r)): return l == r
  case (.null, .null): return true
  case (.bool(let l), .bool(let r)): return l == r
  case (.string(let l), .string(let r)): return l == r
  case (.double(let l), .double(let r)): return l == r
  case (.integer(let l), .integer(let r)): return l == r
  default: return false
  }
}
