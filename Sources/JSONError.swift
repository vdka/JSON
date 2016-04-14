
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

/// Throws the error passed to it. Can be used with nil coalescing (??) to throw an error on nil.
public func raise<T>(error: ErrorType) throws -> T { throw error }
