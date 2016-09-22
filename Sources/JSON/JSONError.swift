

extension JSON {

  /// Represent an error resulting during mapping either, to or from an instance type.
  public enum Error: Swift.Error {

    // BadField indicates an error where a field was missing or was of the wrong type. The associated value represents the name of the field.
    case badField(String)
    /// When thrown during initialization it indicates a value in the JSON could not be converted to RFC
    case badValue(JSON)
    /// A number was not valid per the JSON spec. (handled in Parser?)
    case invalidNumber
  }
}
