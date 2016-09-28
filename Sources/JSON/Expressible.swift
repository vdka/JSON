

extension JSON: ExpressibleByArrayLiteral {
  public init(arrayLiteral elements: JSONRepresentable...) {
    self = .array(elements.map(JSON.init))
  }
}

extension JSON: ExpressibleByDictionaryLiteral {
  public init(dictionaryLiteral elements: (String, JSONRepresentable)...) {

    var dict: [String: JSON] = [:]

    for (key, value) in elements {
      dict[key] = value.encoded()
    }

    self = .object(dict)
  }
}

extension JSON: ExpressibleByIntegerLiteral {
  public init(integerLiteral value: IntegerLiteralType) {
    let val = Int64(value)
    self = .integer(val)
  }
}

extension JSON: ExpressibleByFloatLiteral {
  public init(floatLiteral value: FloatLiteralType) {
    let val = Double(value)
    self = .double(val)
  }
}

extension JSON: ExpressibleByStringLiteral {
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

extension JSON: ExpressibleByNilLiteral {
  public init(nilLiteral: ()) {
    self = .null
  }
}

extension JSON: ExpressibleByBooleanLiteral {
  public init(booleanLiteral value: Bool) {
    self = .bool(value)
  }
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
      return String(describing: error)
    }
  }
}

extension JSON: CustomDebugStringConvertible {
  public var debugDescription: String {
    do {
      return try self.serialized(options: .prettyPrint)
    } catch {
      return String(describing: error)
    }
  }
}
