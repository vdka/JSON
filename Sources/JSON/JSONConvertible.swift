

public protocol JSONConvertible: JSONInitializable, JSONRepresentable {}

extension JSON: JSONConvertible {

  public init(json: JSON) throws {
    self = json
  }

  public func encoded() -> JSON {
    return self
  }
}
