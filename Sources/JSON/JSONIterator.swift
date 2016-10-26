
extension JSON: Sequence {

  public func makeIterator() -> AnyIterator<JSON> {

    switch self {
    case .array(let array):
      var iterator = array.makeIterator()
      return AnyIterator {
        return iterator.next()
      }

    case .object(let object):
      var iterator = object.makeIterator()
      return AnyIterator {
        guard let (key, value) = iterator.next() else { return nil }

        return .object([key: value])
      }

    default:

      var value: JSON? = self

      return AnyIterator {
        defer { value = nil }
        if case .null? = value { return nil }
        return value
      }
    }
  }
}
