

// MARK: - VDKA/JSON

/// Any value that can be expressed in JSON has a representation in `JSON`.
public enum JSON {
  case object([(String, JSON)])
  case array([JSON])
  case null
  case bool(Bool)
  case string(String)
  case integer(Int64)
  case double(Double)
}


// MARK: - JSON: CustomStringConvertible

extension JSON {

  /**
   Turns a nested graph of `JSON`s into a Swift `String`. This produces JSON data that
   strictly conforms to [RFT7159](https://tools.ietf.org/html/rfc7159).
   It can optionally pretty-print the output for debugging, but this comes with a non-negligible performance cost.
   */
  public func serialized(options: JSON.Serializer.Option = []) throws -> String {
    return try JSON.Serializer.serialize(self, options: options)
  }
}

extension JSON: CustomStringConvertible {
  public var description: String {
    do {
      return try self.serialized()
    } catch {
      return String(error)
    }
  }
}

extension JSON: CustomDebugStringConvertible {
  public var debugDescription: String {
    do {
      return try self.serialized(options: [.prettyPrint, .noSkipNull])
    } catch {
      return String(error)
    }
  }
}


// MARK: - JSON Equatable conformance

extension JSON: Equatable {}
public func ==(lhs: JSON, rhs: JSON) -> Bool {
  switch (lhs, rhs) {
  case (.null, .null): return true
  case (.bool(let l), .bool(let r)): return l == r
  case (.array(let l), .array(let r)): return l == r
  case (.string(let l), .string(let r)): return l == r
  case (.double(let l), .double(let r)): return l == r
  case (.integer(let l), .integer(let r)): return l == r

  case (.object(let l), .object(let r)):
    for (l, r) in zip(l, r) {
      guard l == r else { return false }
    }
    return true

  default: return false
  }
}


// MARK: - JSON LiteralConvertible conformance

extension JSON: ArrayLiteralConvertible {
  public init(arrayLiteral elements: JSONEncodable...) {
    self = .array(elements.map(JSON.init))
  }
}

extension JSON: DictionaryLiteralConvertible {
  public init(dictionaryLiteral elements: (String, JSONEncodable)...) {
    var dict: [(String, JSON)] = []
    for (k, v) in elements {
      dict.append( (k, v.encoded()) )
    }

    self = .object(dict)
  }
}

extension JSON: IntegerLiteralConvertible {
  public init(integerLiteral value: IntegerLiteralType) {
    let val = Int64(value)
    self = .integer(val)
  }
}

extension JSON: FloatLiteralConvertible {
  public init(floatLiteral value: FloatLiteralType) {
    let val = Double(value)
    self = .double(val)
  }
}

extension JSON: StringLiteralConvertible {
  public init(stringLiteral value: String) {
    self = .string(value)
  }

  public init(extendedGraphemeClusterLiteral value: String) {
    self = .string(value)
  }

  public init(unicodeScalarLiteral value: String) {
    self = .string(value)
  }
}

extension JSON: NilLiteralConvertible {
  public init(nilLiteral: ()) {
    self = .null
  }
}

extension JSON: BooleanLiteralConvertible {
  public init(booleanLiteral value: Bool) {
    self = .bool(value)
  }
}

