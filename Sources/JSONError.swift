
// MARK: - JSONError

extension JSON {
  /// Represent an error resulting during mapping either, to or from an instance type.
  public enum Error: ErrorType {
  	/// BadField indicates an error where a field was missing or was of the wrong type. The associated value represents the name of the field.
  	case BadField(String)
    /// When thrown during initialization it indicates a value in the JSON could not be converted to RFC
  	case BadValue(Any)
    /// A number was not valid per the JSON spec. (handled in Parser?)
    case InvalidNumber
    ///
    case NonJSONType
  }
}


// TODO: precedence associativity?
// TODO: should I be overloading an existing operator?

infix operator ?? { associativity right precedence 131 }

/// Throws the error on the right side. Use to throw on nil.
public func ??<T>(lhs: T?, @autoclosure error: () -> ErrorType) throws -> T {
  guard case .Some(let value) = lhs else { throw error() }
  return value
}
