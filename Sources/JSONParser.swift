
import Darwin.C

// TODO(vdka): Determine the approach for using OpenSwift streams without actually depending upon them.
//  Thinking declare a JSON.Parser.Stream that is this protocol (the minimum require information to parse from a stream)
//  Consumers would then be able to implement the protocol with whatever Type they want to use.
// NOTE(vdka): Could maybe conform an Array to simplify code in the future
public protocol UTF8Stream {

  func read(to sync: ([UTF8.CodeUnit]) -> Void, length: Int) throws -> Int
}

// MARK: - JSON.Parser

extension JSON {

  public struct Parser {

    // TODO(vdka): rename
    static let chunkSize = 512

    public struct Option: OptionSet {
      public init(rawValue: UInt8) { self.rawValue = rawValue }
      public let rawValue: UInt8

      /// Do not remove null values from the resulting JSON value. Instead store `JSON.null`
      public static let skipNull        = Option(rawValue: 0b0001)

      /// Allows Parser to return top level objects that are not container types `{}` | `[]` as per RFC7159
      public static let allowFragments  = Option(rawValue: 0b0010)
    }

    let skipNull: Bool

    var index: Int
    //var buffer: UnsafeBufferPointer<UTF8.CodeUnit>

    // Buffer is used for the parser to read from
    var buffer: [UTF8.CodeUnit]

    // Stream buffer is used for the stream to read into!
    var streamBuffer: [UTF8.CodeUnit]

    var stream: UTF8Stream?

    /// Used to reduce the number of alloc's for parsing subsequent strings
    var stringBuffer: [UTF8.CodeUnit] = []
  }
}


// MARK: - Initializers

extension JSON.Parser {

  internal init(buffer: [UTF8.CodeUnit]?, stream: UTF8Stream?, options: Option) throws {

    if let buffer = buffer {
      self.buffer = buffer
      self.streamBuffer = []
    } else {
      var buffer: [UTF8.CodeUnit] = []
      // TODO(vdka): Find a good default buffer size?
      buffer.reserveCapacity(JSON.Parser.chunkSize)
      self.buffer = buffer
      self.streamBuffer = buffer
    }

    self.index = buffer!.startIndex

    self.stream = stream

    self.skipNull = options.contains(.skipNull)

    self.skipWhitespace()

    if !options.contains(.allowFragments) {
      guard let firstToken = peek(), firstToken == objectOpen || firstToken == arrayOpen else { throw Error.Reason.fragmentedJson }
    }
  }
}


// MARK: - Public API

extension JSON.Parser {

  public static func parse(_ stream: UTF8Stream, options: Option = []) throws -> JSON {

    var parser = try JSON.Parser(buffer: nil, stream: stream, options: options)

    do {

      let rootValue = try parser.parseValue()
      parser.skipWhitespace()

      // TODO(vkda): option to skip the trailing data check, useful for say streams see Jay's model
      //  Find a way to implement the above TODO ensuring we are at the end of the buffer will not work here.
      //  We could check that the input stream is _drained_

      return rootValue

    } catch let error as Error.Reason {

      // TODO(vdka): return to throwing _useful_ errors. with context
      throw Error(byteOffset: 0, reason: error)
    }
  }

  public static func parse(_ buffer: [UTF8.CodeUnit], options: Option = []) throws -> JSON {


    do {

      guard !buffer.isEmpty else { throw Error.Reason.emptyStream }

      var parser = try JSON.Parser(buffer: buffer, stream: nil, options: options)
      
      let rootValue = try parser.parseValue()
      parser.skipWhitespace()

      // TODO(vkda): option to skip the trailing data check, useful for say streams see Jay's model
      //  Find a way to implement the above TODO ensuring we are at the end of the buffer will not work here.
      //  We could check that the input stream is _drained_

      return rootValue

    } catch let error as Error.Reason {

      // TODO(vdka): return to throwing _useful_ errors. with context
      throw Error(byteOffset: 0, reason: error)
    }
  }

  // NOTE(vdka): This is probably a bit too easy to get wrong and should not be public.
  /// - Parameter stream: When given a stream the parser will call stream.read whenever the data runs out.
  // public static func parse(_ data: [UTF8.CodeUnit] = [], options: Option = []) throws -> JSON {

  public static func parse(_ string: String, options: Option = []) throws -> JSON {

    let data = Array(string.utf8)

    return try JSON.Parser.parse(data, options: options)
  }

}


// MARK: - Internals

extension JSON.Parser {

  /// This *shall* only be called when the input buffer we are reading from has been read to the end.
  mutating func read() throws {

    guard let stream = stream else { throw Error.Reason.endOfStream }

    func insertIntoBuffer(_ bytes: [UTF8.CodeUnit]) {

      streamBuffer.removeAll(keepingCapacity: true)
      streamBuffer.append(contentsOf: bytes)
    }

    // Read `chundkSize` bytes from the stream, inserting them into my buffer

    _ = try stream.read(to: insertIntoBuffer, length: JSON.Parser.chunkSize)

    index = buffer.startIndex
  }

  // If when we peek ahead we see a nil value then we need to wait for the stream to send us more data. If we have one that is.
  func peek(aheadBy n: Int = 0) -> UTF8.CodeUnit? {

    guard index.advanced(by: n) < buffer.endIndex else {
      return nil
    }

    return buffer[index.advanced(by: n)]
  }

  mutating func pop() throws -> UTF8.CodeUnit {

    // TODO(vdka): there is at least the crashing case where peek probably should handle this? because peek(aheadBy n:_) is gonna cause issues.
    guard index < buffer.endIndex else {
      try read()
      buffer = streamBuffer
      index = 0
      return buffer[index]
    }

    defer { index = index.advanced(by: 1) }
    return buffer[index]

  }

  @discardableResult
  mutating func unsafePop() -> UTF8.CodeUnit {
    defer { index = index.advanced(by: 1) }
    return buffer[index]

    // defer { pointer = pointer.advanced(by: 1) }
    // return pointer.pointee
  }
}

extension JSON.Parser {

  mutating func skipWhitespace() {

    while index != buffer.endIndex && buffer[index].isWhitespace {

      unsafePop()
    }
  }
}

extension JSON.Parser {

  /**
   - precondition: `pointer` is at the beginning of a literal
   - postcondition: `pointer` will be in the next non-`whiteSpace` position
   */
  mutating func parseValue() throws -> JSON {

    assert(!buffer[index].isWhitespace)

    defer { skipWhitespace() }
    switch peek() {
    case objectOpen?:

      let object = try parseObject()
      return object

    case arrayOpen?:

      let array = try parseArray()
      return array

    case quote?:

      let string = try parseString()
      return .string(string)

    case minus?, numbers?:

      let number = try parseNumber()
      return number

    case f?:

      unsafePop()
      try assertFollowedBy(alse)
      return .bool(false)

    case t?:

      unsafePop()
      try assertFollowedBy(rue)
      return .bool(true)

    case n?:

      unsafePop()
      try assertFollowedBy(ull)
      return .null

    case nil:
      throw Error.Reason.endOfStream

    default:
      throw Error.Reason.invalidSyntax
    }
  }

  mutating func assertFollowedBy(_ chars: [UTF8.CodeUnit]) throws {

    for scalar in chars {

      let got = try pop()

      guard try scalar == got else {
        throw Error.Reason.invalidLiteral
      }
    }
  }

  mutating func parseObject() throws -> JSON {

    assert(peek() == objectOpen)
    unsafePop()

    skipWhitespace()

    guard peek() != objectClose else {
      unsafePop()
      return .object([:])
    }

    var tempDict: [String: JSON] = Dictionary(minimumCapacity: 6)
    var wasComma = false

    repeat {

      switch peek() {
      case comma?:

        guard !wasComma else { throw Error.Reason.trailingComma }

        wasComma = true
        unsafePop()
        skipWhitespace()

      case quote?:

        if tempDict.count > 0 && !wasComma {
          throw Error.Reason.expectedComma
        }

        let key = try parseString()
        try skipColon()
        let value = try parseValue()
        wasComma = false

        switch value {
        case .null where skipNull:
          break

        default:
          tempDict[key] = value
        }

      case objectClose?:

        guard !wasComma else { throw Error.Reason.trailingComma }

        unsafePop()
        return .object(tempDict)

      case nil:
        throw Error.Reason.endOfStream

      default:
        throw Error.Reason.invalidSyntax
      }
    } while true
  }

  mutating func parseArray() throws -> JSON {

    assert(peek() == arrayOpen)
    unsafePop()

    skipWhitespace()

    // Saves the allocation of the tempArray
    guard peek() != arrayClose else {
      unsafePop()
      return .array([])
    }

    var tempArray: [JSON] = []
    tempArray.reserveCapacity(6)

    var wasComma = false

    repeat {

      switch peek() {
      case comma?:

        guard !wasComma else { throw Error.Reason.invalidSyntax }
        guard tempArray.count > 0 else { throw Error.Reason.invalidSyntax }

        wasComma = true
        try skipComma()

      case arrayClose?:

        guard !wasComma else { throw Error.Reason.trailingComma }

        _ = try pop()
        return .array(tempArray)

      case nil:
        throw Error.Reason.endOfStream

      default:

        if tempArray.count > 0 && !wasComma {
          throw Error.Reason.expectedComma
        }

        let value = try parseValue()
        skipWhitespace()
        wasComma = false

        switch value {
        case .null where skipNull:
          if peek() == comma {
            try skipComma()
          }

        default:
          tempArray.append(value)
        }
      }
    } while true
  }


  // TODO(vdka): No leading 0's it's against the spec.
  mutating func parseNumber() throws -> JSON {

    assert(numbers ~= peek()! || minus == peek()!)

    var seenExponent = false
    var seenDecimal = false

    let negative: Bool = {
      guard minus == peek() else { return false }
      unsafePop()
      return true
    }()

    guard let next = peek() else { throw Error.Reason.invalidNumber }
    // Checks for leading zero's on numbers that are not '0' or '0.x'
    if next == zero {
      // look at 
      guard let following = peek(aheadBy: 1) else { return .integer(0) }
      guard following == decimal || following.isTerminator else { throw Error.Reason.invalidNumber }
    }

    var significand: UInt64 = 0
    var mantisa: UInt64 = 0
    var divisor: Double = 10
    var exponent: UInt64 = 0
    var negativeExponent = false
    var didOverflow: Bool

    repeat {

      switch peek() {
      case numbers? where !seenDecimal && !seenExponent:

        (significand, didOverflow) = UInt64.multiplyWithOverflow(significand, 10)
        guard !didOverflow else { throw Error.Reason.numberOverflow }

        (significand, didOverflow) = UInt64.addWithOverflow(significand, UInt64(unsafePop() - zero))
        guard !didOverflow else { throw Error.Reason.numberOverflow }

      case numbers? where seenDecimal && !seenExponent:

        divisor *= 10

        (mantisa, didOverflow) = UInt64.multiplyWithOverflow(mantisa, 10)
        guard !didOverflow else { throw Error.Reason.numberOverflow }

        (mantisa, didOverflow) = UInt64.addWithOverflow(mantisa, UInt64(unsafePop() - zero))
        guard !didOverflow else { throw Error.Reason.numberOverflow }

      case numbers? where seenExponent:

        (exponent, didOverflow) = UInt64.multiplyWithOverflow(exponent, 10)
        guard !didOverflow else { throw Error.Reason.numberOverflow }

        (exponent, didOverflow) = UInt64.addWithOverflow(exponent, UInt64(unsafePop() - zero))
        guard !didOverflow else { throw Error.Reason.numberOverflow }

      case decimal? where !seenExponent && !seenDecimal:

        unsafePop()
        seenDecimal = true
        guard let next = peek(), numbers ~= next else { throw Error.Reason.invalidNumber }

      case E? where !seenExponent,
           e? where !seenExponent:

        unsafePop()
        seenExponent = true

        if peek() == minus {

          negativeExponent = true
          unsafePop()
        } else if peek() == plus {

          unsafePop()
        }

        guard let next = peek(), numbers ~= next else { throw Error.Reason.invalidNumber }

      case let value? where value.isTerminator:
        fallthrough

      case nil:

        return try constructNumber(
          significand: significand,
          mantisa: seenDecimal ? mantisa : nil,
          exponent: seenExponent ? exponent : nil,
          divisor: divisor,
          negative: negative,
          negativeExponent: negativeExponent
        )

      default:
        throw Error.Reason.invalidNumber
      }
    } while true
  }

  func constructNumber(significand: UInt64, mantisa: UInt64?, exponent: UInt64?, divisor: Double, negative: Bool, negativeExponent: Bool) throws -> JSON {

    if mantisa != nil || exponent != nil {
      var divisor = divisor

      divisor /= 10

      let number = Double(negative ? -1 : 1) * (Double(significand) + Double(mantisa ?? 0) / divisor)

      if let exponent = exponent {
        return .double(Double(number) * pow(10, negativeExponent ? -Double(exponent) : Double(exponent)))
//        return .double(number.power(10, exponent: exponent, isNegative: negativeExponent))
      } else {
        return .double(number)
      }

    } else {

      switch significand {
      case validUnsigned64BitInteger where !negative:
        return .integer(Int64(significand))

      case UInt64(Int64.max) + 1 where negative:
        return .integer(Int64.min)

      case validUnsigned64BitInteger where negative:
        return .integer(-Int64(significand))

      default:
        throw Error.Reason.invalidNumber
      }
    }
  }

  // TODO (vdka): refactor
  // TODO (vdka): option to _repair_ Unicode
  mutating func parseString() throws -> String {

    assert(peek() == quote)
    unsafePop()

    var escaped = false
    stringBuffer.removeAll(keepingCapacity: true)

    repeat {

      let codeUnit = try pop()
      if codeUnit == backslash && !escaped {

        escaped = true
      } else if codeUnit == quote && !escaped {

        stringBuffer.append(0)
        let string = stringBuffer.withUnsafeBufferPointer { bufferPointer in
          return String(cString: unsafeBitCast(bufferPointer.baseAddress, to: UnsafePointer<CChar>.self))
        }

        return string
      } else if escaped {

        switch codeUnit {
        case r:
          stringBuffer.append(cr)

        case t:
          stringBuffer.append(tab)

        case n:
          stringBuffer.append(newline)

        case b:
          stringBuffer.append(backspace)

        case quote:
          stringBuffer.append(quote)

        case slash:
          stringBuffer.append(slash)

        case backslash:
          stringBuffer.append(backslash)

        case u:
          let scalar = try parseUnicodeScalar()
          var bytes: [UTF8.CodeUnit] = []
          UTF8.encode(scalar, into: { bytes.append($0) })
          stringBuffer.append(contentsOf: bytes)

        default:
          throw Error.Reason.invalidEscape
        }

        escaped = false

      } else {

        stringBuffer.append(codeUnit)
      }
    } while true
  }
}

extension JSON.Parser {

  mutating func parseUnicodeEscape() throws -> UTF16.CodeUnit {

    var codeUnit: UInt16 = 0
    for _ in 0..<4 {
      let c = try pop()
      codeUnit <<= 4
      switch c {
      case numbers:
        codeUnit += UInt16(c - 48)
      case alphaNumericLower:
        codeUnit += UInt16(c - 87)
      case alphaNumericUpper:
        codeUnit += UInt16(c - 55)
      default:
        throw Error.Reason.invalidEscape
      }
    }

    return codeUnit
  }

  mutating func parseUnicodeScalar() throws -> UnicodeScalar {

    // For multi scalar Unicodes eg. flags
    var buffer: [UInt16] = []

    let codeUnit = try parseUnicodeEscape()
    buffer.append(codeUnit)

    if UTF16.isLeadSurrogate(codeUnit) {

      guard try pop() == backslash && pop() == u else { throw Error.Reason.invalidUnicode }
      let trailingSurrogate = try parseUnicodeEscape()
      buffer.append(trailingSurrogate)
    }

    var gen = buffer.makeIterator()

    var utf = UTF16()

    switch utf.decode(&gen) {
    case .scalarValue(let scalar):
      return scalar

    case .emptyInput, .error:
      throw Error.Reason.invalidUnicode
    }
  }

  mutating func skipColon() throws {
    skipWhitespace()
    guard case colon = try pop() else { throw Error.Reason.expectedColon }
    skipWhitespace()
  }

  mutating func skipComma() throws {
    skipWhitespace()
    guard case comma = try pop() else { throw Error.Reason.expectedComma }
    skipWhitespace()
  }
}

extension JSON.Parser {

  public struct Error: Swift.Error, Equatable {

    public var byteOffset: Int

    public var reason: Reason

    public enum Reason: Swift.Error {

      case endOfStream
      case emptyStream
      case trailingComma
      case expectedComma
      case expectedColon
      case invalidEscape
      case invalidSyntax
      case invalidNumber
      case numberOverflow
      case invalidLiteral
      case invalidUnicode
      case fragmentedJson
    }

    public static func == (lhs: JSON.Parser.Error, rhs: JSON.Parser.Error) -> Bool {
      return lhs.byteOffset == rhs.byteOffset && lhs.reason == rhs.reason
    }
  }
}


// MARK: - Stdlib extensions

extension UTF8.CodeUnit {

  var isWhitespace: Bool {
    if self == space || self == tab || self == cr || self == newline || self == formfeed {
      return true
    }

    return false
  }

  var isTerminator: Bool {
    if self.isWhitespace || self == comma || self == objectClose || self == arrayClose {
      return true
    }

    return false
  }
}
