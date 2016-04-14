

// MARK: - JSONSerializer

/**
 Turns a nested graph of `JSON`s into a Swift `String`. This produces JSON data that
 strictly conforms to [ECMA-404](http://www.ecma-international.org/publications/files/ECMA-ST/ECMA-404.pdf).
 It can optionally pretty-print the output for debugging, but this comes with a non-negligible performance cost.
 */
public final class JSONSerializer {
  
  public struct Option: OptionSetType {
    public init(rawValue: UInt8) { self.rawValue = rawValue }
    public let rawValue: UInt8
    
    /// Serialize `JSON.null` instead of skipping it
    public static let noSkipNull = Option(rawValue: 1 << 1)
    /// Serialize with formatting for user readability
    public static let prettyPrint = Option(rawValue: 1 << 2)
    /// When specified with `.prettyPrint` will use windows style newlines for formatting. Boo.
    public static let windowsLineEndings = Option(rawValue: 1 << 3)
  }
  
  /**
   Shortcut for creating a `JSONSerializer` and having it serialize the given
   `JSON`.
   - Returns: The serialized value as a `String`.
   - Throws: A `JSONSerializer.Error` if something failed during serialization.
   */
  public class func serialize(json: JSON, options: [Option] = []) throws -> String {
    return try JSONSerializer(value: json, options: options).serialize()
  }
  
  /**
   Shortcut for creating a `JSONSerializer` and having it serialize the given
   `JSONEncodable` value.
   - Returns: The serialized value as a `String`.
   - Throws: A `JSONSerializer.Error` if something failed during serialization.
   */
  public class func serialize(object: JSONEncodable, options: [Option] = []) throws -> String {
    return try JSONSerializer(value: object.encoded(), options: options).serialize()
  }
  
  
  // MARK: - Internals: Initializers
  
  internal init(value: JSON, options: [Option]) {
    self.skipNull = !options.contains(.noSkipNull)
    self.prettyPrint = options.contains(.prettyPrint)
    self.lineEndings = options.contains(.windowsLineEndings) ? .Windows : .Unix
    self.rootValue = value
  }
  
  
  // MARK: - Internals: Functions
  
  internal func serialize() throws -> String {
    try serializeValue(rootValue)
    return output
  }
  
  
  // MARK: - Internals: Properties
  
  /// What line endings should the pretty printer use
  enum LineEndings: String {
    /// Unix (i.e Linux, Darwin) line endings: line feed
    case Unix = "\n"
    /// Windows line endings: carriage return + line feed
    case Windows = "\r\n"
  }
  
  let skipNull: Bool
  let prettyPrint: Bool
  let lineEndings: LineEndings
  let rootValue: JSON
  var output: String = ""
}


// MARK: - Serialized convenience method.

extension JSON {
  
  /**
   Turns a nested graph of `JSON`s into a Swift `String`. This produces JSON data that
   strictly conforms to [ECMA-404](http://www.ecma-international.org/publications/files/ECMA-ST/ECMA-404.pdf).
   It can optionally pretty-print the output for debugging, but this comes with a non-negligible performance cost.
   */
  // This is nice, but it doesn't work with the Swift 2.1 compiler in Release mode
  public func serialized(options options: [JSONSerializer.Option] = []) throws -> String {
    return try JSONSerializer.serialize(self, options: options)
  }
}

extension JSONEncodable {
  
  /**
   Turns a nested graph of `JSON`s into a Swift `String`. This produces JSON data that
   strictly conforms to [ECMA-404](http://www.ecma-international.org/publications/files/ECMA-ST/ECMA-404.pdf).
   It can optionally pretty-print the output for debugging, but this comes with a non-negligible performance cost.
   */
  // This is nice, but it doesn't work with the Swift 2.1 compiler in Release mode
  public func serialized(options options: [JSONSerializer.Option] = []) throws -> String {
    return try JSONSerializer.serialize(self, options: options)
  }
}


// MARK: - JSONSerializer Errors

extension JSONSerializer {
  /// Errors raised while serializing to a JSON string
  public enum Error: ErrorType {
    /// A number not supported by the JSON spec was encountered, like infinity or NaN.
    case InvalidNumber
  }
}

extension JSONSerializer.Error: Equatable {}
public func == (lhs: JSONSerializer.Error, rhs: JSONSerializer.Error) -> Bool {
  switch (lhs, rhs) {
  case (.InvalidNumber, .InvalidNumber): return true
  }
}

extension JSONSerializer.Error: CustomStringConvertible {
  /// Returns a `String` version of the error which can be logged.
  public var description: String {
    switch self {
    case .InvalidNumber:
      return "Invalid number"
    }
  }
}


// MARK: JSONSerializer Internals

extension JSONSerializer {
  
  func serializeValue(value: JSON, indentLevel: Int = 0) throws {
    switch value {
    case .double(let d):
      try serializeDouble(d)
    case .integer(let i):
      serializeInt(i)
    case .null:
      serializeNull()
    case .string(let s):
      serializeString(s)
    case .object(let obj):
      try serializeObject(obj, indentLevel: indentLevel)
    case .bool(let b):
      serializeBool(b)
    case .array(let a):
      try serializeArray(a, indentLevel: indentLevel)
    }
  }
  
  func serializeObject(obj: [String : JSON], indentLevel: Int = 0) throws {
    output.append(leftCurlyBracket)
    serializeNewline()
    var i = 0
    var nullsFound = 0
    for (key, value) in obj {
      if skipNull && value == .null {
        nullsFound = nullsFound.successor()
        continue
      }
      if i != 0 && i != obj.count - nullsFound {
        output.append(comma)
        serializeNewline()
      }
      serializeSpaces(indentLevel + 1)
      serializeString(key)
      output.append(colon)
      if prettyPrint {
        output.appendContentsOf(" ")
      }
      try serializeValue(value, indentLevel: indentLevel + 1)
      i += 1
    }
    serializeNewline()
    serializeSpaces(indentLevel)
    output.append(rightCurlyBracket)
  }
  
  func serializeArray(arr: [JSON], indentLevel: Int = 0) throws {
    output.append(leftSquareBracket)
    serializeNewline()
    var i = 0
    var nullsFound = 0
    for val in arr {
      if skipNull && val == .null {
        nullsFound = nullsFound.successor()
        continue
      }
      if i != 0 && i != arr.count - nullsFound {
        output.append(comma)
        serializeNewline()
      }
      serializeSpaces(indentLevel + 1)
      try serializeValue(val, indentLevel: indentLevel + 1)
      i += 1
    }
    serializeNewline()
    serializeSpaces(indentLevel)
    output.append(rightSquareBracket)
  }
  
  func serializeString(str: String) {
    output.append(quotationMark)
    var generator = str.unicodeScalars.generate()
    while let scalar = generator.next() {
      switch scalar.value {
      case solidus.value:
        fallthrough
      case 0x0000...0x001F:
        output.append(reverseSolidus)
        switch scalar {
        case tabCharacter:
          output.appendContentsOf("t")
        case carriageReturn:
          output.appendContentsOf("r")
        case lineFeed:
          output.appendContentsOf("n")
        case quotationMark:
          output.append(quotationMark)
        case backspace:
          output.appendContentsOf("b")
        case solidus:
          output.append(solidus)
        default:
          output.appendContentsOf("u")
          output.append(hexScalars[(Int(scalar.value) & 0xF000) >> 12])
          output.append(hexScalars[(Int(scalar.value) & 0x0F00) >> 8])
          output.append(hexScalars[(Int(scalar.value) & 0x00F0) >> 4])
          output.append(hexScalars[(Int(scalar.value) & 0x000F) >> 0])
        }
      default:
        output.append(scalar)
      }
    }
    output.append(quotationMark)
  }
  
  func serializeDouble(f: Double) throws {
    guard f.isFinite else { throw JSONSerializer.Error.InvalidNumber }
    // TODO: Is CustomStringConvertible for number types affected by locale?
    // TODO: Is CustomStringConvertible for Double fast?
    output.appendContentsOf(f.description)
  }
  
  func serializeInt(i: Int64) {
    // TODO: Is CustomStringConvertible for number types affected by locale?
    output.appendContentsOf(i.description)
  }
  
  func serializeBool(bool: Bool) {
    switch bool {
    case true:
      output.appendContentsOf("true")
    case false:
      output.appendContentsOf("false")
    }
  }
  
  func serializeNull() {
    output.appendContentsOf("null")
  }
  
  @inline(__always)
  private final func serializeNewline() {
    if prettyPrint {
      output.appendContentsOf(lineEndings.rawValue)
    }
  }
  
  @inline(__always)
  private final func serializeSpaces(indentLevel: Int = 0) {
    if prettyPrint {
      for _ in 0..<indentLevel {
        output.appendContentsOf("  ")
      }
    }
  }
}
