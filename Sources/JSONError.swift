
// MARK: - JSONError

extension JSON {
  /// Represent an error resulting during mapping either, to or from an instance type.
  public enum Error: ErrorProtocol {
    // BadField indicates an error where a field was missing or was of the wrong type. The associated value represents the name of the field.
    case badField(String)
    /// When thrown during initialization it indicates a value in the JSON could not be converted to RFC
    case badValue(Any)
    /// A number was not valid per the JSON spec. (handled in Parser?)
    case invalidNumber
    ///
    case nonJSONType
  }
}


// DISCUSS: should I be overloading an existing operator?

// associativity and precedence set to match stlib ?? operator.
infix operator ?? { associativity right precedence 131 }

/// Throws the error on the right side. Use to throw on nil.
public func ??<T>(lhs: T?, error: @autoclosure() -> ErrorProtocol) throws -> T {
  guard case .some(let value) = lhs else { throw error() }
  return value
}

