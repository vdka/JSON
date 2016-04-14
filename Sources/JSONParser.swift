
// MARK:- Unicode Scalars

internal let leftSquareBracket = UnicodeScalar(0x005b)
internal let leftCurlyBracket = UnicodeScalar(0x007b)
internal let rightSquareBracket = UnicodeScalar(0x005d)
internal let rightCurlyBracket = UnicodeScalar(0x007d)

//internal let colon = UnicodeScalar(0x003A)
//internal let comma = UnicodeScalar(0x002C)
internal let colon = ":".unicodeScalars.first!
internal let comma = ",".unicodeScalars.first!
internal let zeroScalar = "0".unicodeScalars.first!
internal let negativeScalar = "-".unicodeScalars.first!
internal let plusScalar = "+".unicodeScalars.first!
internal let decimalScalar = ".".unicodeScalars.first!
internal let quotationMark = "\"".unicodeScalars.first!
internal let lineFeed = UnicodeScalar(0x000A)

// String escapes
internal let reverseSolidus = "\\".unicodeScalars.first!
internal let solidus = "/".unicodeScalars.first!
internal let backspace = UnicodeScalar(0x0008)

internal let space = " ".unicodeScalars.first!
internal let carriageReturn = UnicodeScalar(0x000D)
internal let formFeed = UnicodeScalar(0x000C)
internal let tabCharacter = UnicodeScalar(0x0009)

internal let trueToken = [UnicodeScalar]("true".unicodeScalars)
internal let falseToken = [UnicodeScalar]("false".unicodeScalars)
internal let nullToken = [UnicodeScalar]("null".unicodeScalars)

internal let escapeMap = [
  "/".unicodeScalars.first!: solidus,
  "b".unicodeScalars.first!: backspace,
  "f".unicodeScalars.first!: formFeed,
  "n".unicodeScalars.first!: lineFeed,
  "r".unicodeScalars.first!: carriageReturn,
  "t".unicodeScalars.first!: tabCharacter
]

internal let hexScalars = [
  "0".unicodeScalars.first!,
  "1".unicodeScalars.first!,
  "2".unicodeScalars.first!,
  "3".unicodeScalars.first!,
  "4".unicodeScalars.first!,
  "5".unicodeScalars.first!,
  "6".unicodeScalars.first!,
  "7".unicodeScalars.first!,
  "8".unicodeScalars.first!,
  "9".unicodeScalars.first!,
  "a".unicodeScalars.first!,
  "b".unicodeScalars.first!,
  "c".unicodeScalars.first!,
  "d".unicodeScalars.first!,
  "e".unicodeScalars.first!,
  "f".unicodeScalars.first!
]


// MARK: - Parser

// The structure of this parser is inspired by the great (and slightly insane) NextiveJson parser:
// https://github.com/nextive/NextiveJson

/**
 Turns a String represented as a collection of Unicode scalars into a nested graph
 of `JSON`s. This is a strict parser implementing [ECMA-404](http://www.ecma-international.org/publications/files/ECMA-ST/ECMA-404.pdf).
 Being strict, it doesn't support common JSON extensions such as comments.
 */
public final class JSONParser {
  
  public struct Option: OptionSetType {
    public init(rawValue: UInt8) { self.rawValue = rawValue }
    public let rawValue: UInt8
    
    /// Do not remove null values from the resulting JSON value. Instead store `JSON.null`
    public static let noSkipNull = Option(rawValue: 1 << 1)
    /// Specifies that the parser should allow top-level objects that are not an instance of Array or Dictionary.
    public static let allowFragments = Option(rawValue: 1 << 2)
  }
  
  /**
   A shortcut for creating a `JSONParser` and having it parse the given `String`.
   This is a blocking operation, and will block the calling thread until parsing
   finishes or throws an error.
   - Parameter string: The `String` of the input JSON.
   - Returns: The root `JSON` node from the input data.
   - Throws: A `JSONParse.Error` if something failed during parsing.
   */
  public class func parse(string: String, options: [Option] = []) throws -> JSON {
    return try JSONParser(data: string.unicodeScalars, options: options).parse()
  }
  
  /**
   Starts parsing the data. This is a blocking operation, and will block the
   calling thread until parsing finishes or throws an error.
   - Returns: The root `JSON` node from the input data.
   - Throws: A `JSONParse.Error` if something failed during parsing.
   */
  internal func parse() throws -> JSON {
    do {
      try nextScalar()
      let value = try nextValue()
      do {
        try nextScalar()
        if scalar.isIgnorable {
          // Skip to EOF or the next token
          try skipToNextToken()
          // If we get this far some token was found ...
          throw JSONParser.Error.UnexpectedCharacter(lineNumber: lineNumber, characterNumber: charNumber)
        } else {
          // There's some weird character at the end of the file...
          throw JSONParser.Error.UnexpectedCharacter(lineNumber: lineNumber, characterNumber: charNumber)
        }
      } catch JSONParser.Error.EndOfFile {
        return value
      }
    } catch JSONParser.Error.EndOfFile {
      throw JSONParser.Error.EmptyInput
    }
  }
  
  
  // MARK: - Internals
  
  
  /**
   Designated initializer for `JSONParser`, which requires an input Unicode scalar
   collection.
   - Parameter data: The Unicode scalars representing the input JSON data.
   */
  internal init(data: String.UnicodeScalarView, options: [Option]) {
    generator = data.generate()
    self.data = data
    self.skipNull = !options.contains(.noSkipNull)
    self.allowFragments = options.contains(.allowFragments)
  }
  
  let allowFragments: Bool
  let skipNull: Bool
  
  var generator: String.UnicodeScalarView.Generator
  let data: String.UnicodeScalarView
  var scalar: UnicodeScalar!
  var lineNumber: UInt = 0
  var charNumber: UInt = 0
  
  var crlfHack = false
  var fragment: Bool = true
  
}


// MARK: - JSONParser Errors

extension JSONParser {
  /// Errors raised while parsing a String into a JSON instance
  public enum Error: ErrorType {
    /// Some unknown error, usually indicates something not yet implemented.
    case Unknown
    /// Input data was either empty or contained only whitespace.
    case EmptyInput
    /// Some character that violates the strict JSON grammar was found.
    case UnexpectedCharacter(lineNumber: UInt, characterNumber: UInt)
    /// A JSON string was opened but never closed.
    case UnterminatedString
    /// Any unicode parsing errors will result in this error. Currently unused.
    case InvalidUnicode
    /// A keyword, like `null`, `true`, or `false` was expected but something else was in the input.
    case UnexpectedKeyword(lineNumber: UInt, characterNumber: UInt)
    /// Encountered a JSON number that couldn't be losslessly stored in a `Double` or `Int64`.
    /// Usually the number is too large or too small.
    case InvalidNumber(lineNumber: UInt, characterNumber: UInt)
    /// End of file reached, not always an actual error.
    case EndOfFile
    /// Fragmented JSON (Elements must appear within `[]` or `{}`)
    case FragmentedJSON
  }
}

extension JSONParser.Error: Equatable {}
public func == (lhs: JSONParser.Error, rhs: JSONParser.Error) -> Bool {
  switch (lhs, rhs) {
  case (.Unknown, .Unknown): return true
  case (.EndOfFile, .EndOfFile): return true
  case (.EmptyInput, .EmptyInput): return true
  case (.InvalidUnicode, .InvalidUnicode): return true
  case (.FragmentedJSON, .FragmentedJSON): return true
  case (.UnterminatedString, .UnterminatedString): return true
  case let (.InvalidNumber(l), .InvalidNumber(r)): return l == r
  case let (.UnexpectedKeyword(l), .UnexpectedKeyword(r)): return l == r
  case let (.UnexpectedCharacter(l), .UnexpectedCharacter(r)): return l == r
  default: return false
  }
}

extension JSONParser.Error: CustomStringConvertible {
  /// Returns a `String` version of the error which can be logged.
  public var description: String {
    switch self {
    case .Unknown:
      return "Unknown error"
    case .EmptyInput:
      return "Empty input"
    case .UnexpectedCharacter(let lineNumber, let charNum):
      return "Unexpected character at \(lineNumber):\(charNum)"
    case .UnterminatedString:
      return "Unterminated string"
    case .InvalidUnicode:
      return "Invalid unicode"
    case .UnexpectedKeyword(let lineNumber, let characterNumber):
      return "Unexpected keyword at \(lineNumber):\(characterNumber)"
    case .EndOfFile:
      return "Unexpected end of file"
    case .InvalidNumber:
      return "Invalid number"
    case .FragmentedJSON:
      return "Fragmented JSON"
    }
  }
}


// MARK: Internal UnicodeScalar extension

extension UnicodeScalar {
  internal var isIgnorable: Bool {
    switch self {
    case space, lineFeed, carriageReturn, tabCharacter: return true
    default: return false
    }
  }
}


// MARK: JSONParser Internals

extension JSONParser {
  
  
  // MARK: - Enumerating the scalar collection
  
  func nextScalar() throws {
    guard let sc = generator.next() else {
      throw JSONParser.Error.EndOfFile
    }
    
    scalar = sc
    charNumber = charNumber + 1
    if crlfHack == true && sc != lineFeed {
      crlfHack = false
    }
  }
  
  @inline(__always)
  func skipToNextToken() throws {
    guard scalar.isIgnorable else {
      throw JSONParser.Error.UnexpectedCharacter(lineNumber: lineNumber, characterNumber: charNumber)
    }
    
    while scalar.isIgnorable {
      if scalar == carriageReturn || scalar == lineFeed {
        if crlfHack == true && scalar == lineFeed {
          crlfHack = false
          charNumber = 0
        } else {
          if (scalar == carriageReturn) {
            crlfHack = true
          }
          lineNumber = lineNumber + 1
          charNumber = 0
        }
      }
      try nextScalar()
    }
  }
  
  func nextScalars(count: UInt) throws -> [UnicodeScalar] {
    var values = [UnicodeScalar]()
    values.reserveCapacity(Int(count))
    for _ in 0..<count {
      try nextScalar()
      values.append(scalar)
    }
    return values
  }
  
  
  // MARK: - Parse loop
  
  func nextValue() throws -> JSON {
    while scalar.isIgnorable {
      try skipToNextToken()
    }
    
    switch scalar {
    case leftCurlyBracket:
      return try nextObject()
    case leftSquareBracket:
      return try nextArray()
    case quotationMark:
      if !allowFragments && fragment {
        throw JSONParser.Error.FragmentedJSON
      }
      return try nextString()
    case trueToken[0], falseToken[0]:
      if !allowFragments && fragment {
        throw JSONParser.Error.FragmentedJSON
      }
      return try nextBool()
    case nullToken[0]:
      if !allowFragments && fragment {
        throw JSONParser.Error.FragmentedJSON
      }
      return try nextNull()
    case "0".unicodeScalars.first!..."9".unicodeScalars.first!,negativeScalar,decimalScalar:
      if !allowFragments && fragment {
        throw JSONParser.Error.FragmentedJSON
      }
      return try nextNumber()
    default:
      throw JSONParser.Error.UnexpectedCharacter(lineNumber: lineNumber, characterNumber: charNumber)
    }
  }
  
  
  // MARK: - Parse a specific, expected type
  
  func nextObject() throws -> JSON {
    fragment = false
    if scalar != leftCurlyBracket {
      throw JSONParser.Error.UnexpectedCharacter(lineNumber: lineNumber, characterNumber: charNumber)
    }
    var dictBuilder: [String: JSON] = [:]
    
    try nextScalar()
    outerLoop: repeat {
      while scalar.isIgnorable {
        try skipToNextToken()
      }
      guard scalar != rightCurlyBracket else {
        // Empty Object
        return JSON.object([:])
      }
      let string = try nextString()
      try nextScalar() // Skip the quotation character
      while scalar.isIgnorable {
        try skipToNextToken()
      }
      if scalar != colon {
        throw JSONParser.Error.UnexpectedCharacter(lineNumber: lineNumber, characterNumber: charNumber)
      }
      try nextScalar() // Skip the ':'
      let value = try nextValue()
      switch value {
      // Skip the closing character for all values except number, which doesn't have one
      case .integer, .double:
        break
      default:
        try nextScalar()
      }
      while scalar.isIgnorable {
        try skipToNextToken()
      }
      guard case .string(let key) = string else { throw JSONParser.Error.Unknown }
      //let key = string.string! // We're pretty confident it's a string since we called nextString() above
      switch (value) {
      case .null where skipNull: break
      default:
        dictBuilder[key] = value
      }
      switch scalar {
      case rightCurlyBracket:
        break outerLoop
      case comma:
        try nextScalar()
      default:
        throw JSONParser.Error.UnexpectedCharacter(lineNumber: lineNumber, characterNumber: charNumber)
      }
      
    } while true
    
    return JSON.object(dictBuilder)
  }
  
  func nextArray() throws -> JSON {
    fragment = false
    if scalar != leftSquareBracket {
      throw JSONParser.Error.UnexpectedCharacter(lineNumber: lineNumber, characterNumber: charNumber)
    }
    var arrBuilder = [JSON]()
    try nextScalar()
    while scalar.isIgnorable {
      try skipToNextToken()
    }
    guard scalar != rightSquareBracket else {
      // Empty array
      return JSON.array(arrBuilder)
    }
    outerLoop: repeat {
      let value = try nextValue()
      switch value {
      // Skip the closing character for all values except number, which doesn't have one
      case .integer, .double:
        break
      default:
        try nextScalar()
      }
      switch value {
      case .null where skipNull: break
      default:
        arrBuilder.append(value)
      }
      while scalar.isIgnorable {
        try skipToNextToken()
      }
      switch scalar {
      case rightSquareBracket:
        break outerLoop
      case comma:
        try nextScalar()
      default:
        throw JSONParser.Error.UnexpectedCharacter(lineNumber: lineNumber, characterNumber: charNumber)
      }
    } while true
    
    return JSON.array(arrBuilder)
  }
  
  func nextString() throws -> JSON {
    if scalar != quotationMark {
      throw JSONParser.Error.UnexpectedCharacter(lineNumber: lineNumber, characterNumber: charNumber)
    }
    try nextScalar() // Skip pas the quotation character
    var strBuilder = ""
    var escaping = false
    outerLoop: repeat {
      // First we should deal with the escape character and the terminating quote
      switch scalar {
      case reverseSolidus:
        // Escape character
        if escaping {
          // Escaping the escape char
          strBuilder.append(reverseSolidus)
        }
        escaping = !escaping
        try nextScalar()
      case quotationMark:
        if escaping {
          strBuilder.append(quotationMark)
          escaping = false
          try nextScalar()
        } else {
          break outerLoop
        }
      default:
        // Now the rest
        if escaping {
          // Handle all the different escape characters
          if let s = escapeMap[scalar] {
            strBuilder.append(s)
            try nextScalar()
          } else if scalar == "u".unicodeScalars.first! {
            let escapedUnicodeValue = try nextUnicodeEscape()
            strBuilder.append(UnicodeScalar(escapedUnicodeValue))
            try nextScalar()
          }
          escaping = false
        } else {
          // Simple append
          strBuilder.append(scalar)
          try nextScalar()
        }
      }
    } while true
    return JSON.string(strBuilder)
  }
  
  func nextUnicodeEscape() throws -> UInt32 {
    if scalar != "u".unicodeScalars.first! {
      throw JSONParser.Error.UnexpectedCharacter(lineNumber: lineNumber, characterNumber: charNumber)
    }
    var readScalar = UInt32(0)
    for _ in 0...3 {
      readScalar = readScalar * 16
      try nextScalar()
      if ("0".unicodeScalars.first!..."9".unicodeScalars.first!).contains(scalar) {
        readScalar = readScalar + UInt32(scalar.value - "0".unicodeScalars.first!.value)
      } else if ("a".unicodeScalars.first!..."f".unicodeScalars.first!).contains(scalar) {
        let aScalarVal = "a".unicodeScalars.first!.value
        let hexVal = scalar.value - aScalarVal
        let hexScalarVal = hexVal + 10
        readScalar = readScalar + hexScalarVal
      } else if ("A".unicodeScalars.first!..."F".unicodeScalars.first!).contains(scalar) {
        let aScalarVal = "A".unicodeScalars.first!.value
        let hexVal = scalar.value - aScalarVal
        let hexScalarVal = hexVal + 10
        readScalar = readScalar + hexScalarVal
      } else {
        throw JSONParser.Error.UnexpectedCharacter(lineNumber: lineNumber, characterNumber: charNumber)
      }
    }
    if readScalar >= 0xD800 && readScalar <= 0xDBFF {
      // UTF-16 surrogate pair
      // The next character MUST be the other half of the surrogate pair
      // Otherwise it's a unicode error
      do {
        try nextScalar()
        if scalar != reverseSolidus {
          throw JSONParser.Error.InvalidUnicode
        }
        try nextScalar()
        let secondScalar = try nextUnicodeEscape()
        if secondScalar < 0xDC00 || secondScalar > 0xDFFF {
          throw JSONParser.Error.InvalidUnicode
        }
        let actualScalar = ((readScalar - 0xD800) * 0x400) + ((secondScalar - 0xDC00) + 0x10000)
        return actualScalar
      } catch JSONParser.Error.UnexpectedCharacter {
        throw JSONParser.Error.InvalidUnicode
      }
    }
    return readScalar
  }
  
  func nextNumber() throws -> JSON {
    var isNegative = false
    var hasDecimal = false
    var hasDigits = false
    var hasExponent = false
    var positiveExponent = false
    var exponent = 0
    var integer: UInt64 = 0
    var decimal: Int64 = 0
    var divisor: Double = 10
    let lineNumAtStart = lineNumber
    let charNumAtStart = charNumber
    
    do {
      outerLoop: repeat {
        switch scalar {
        case "0".unicodeScalars.first!..."9".unicodeScalars.first!:
          hasDigits = true
          if hasDecimal {
            decimal *= 10
            decimal += Int64(scalar.value - zeroScalar.value)
            divisor *= 10
          } else {
            integer *= 10
            integer += UInt64(scalar.value - zeroScalar.value)
          }
          try nextScalar()
        case negativeScalar:
          if hasDigits || hasDecimal || hasDigits || isNegative {
            throw JSONParser.Error.UnexpectedCharacter(lineNumber: lineNumber, characterNumber: charNumber)
          } else {
            isNegative = true
          }
          try nextScalar()
        case decimalScalar:
          if hasDecimal {
            throw JSONParser.Error.UnexpectedCharacter(lineNumber: lineNumber, characterNumber: charNumber)
          } else {
            hasDecimal = true
          }
          try nextScalar()
        case "e".unicodeScalars.first!,"E".unicodeScalars.first!:
          if hasExponent {
            throw JSONParser.Error.UnexpectedCharacter(lineNumber: lineNumber, characterNumber: charNumber)
          } else {
            hasExponent = true
          }
          try nextScalar()
          switch scalar {
          case "0".unicodeScalars.first!..."9".unicodeScalars.first!:
            positiveExponent = true
          case plusScalar:
            positiveExponent = true
            try nextScalar()
          case negativeScalar:
            positiveExponent = false
            try nextScalar()
          default:
            throw JSONParser.Error.UnexpectedCharacter(lineNumber: lineNumber, characterNumber: charNumber)
          }
          exponentLoop: repeat {
            if scalar.value >= zeroScalar.value && scalar.value <= "9".unicodeScalars.first!.value {
              exponent *= 10
              exponent += Int(scalar.value - zeroScalar.value)
              try nextScalar()
            } else {
              break exponentLoop
            }
          } while true
        default:
          break outerLoop
        }
      } while true
    } catch JSONParser.Error.EndOfFile {
      // This is fine
    }
    
    if !hasDigits {
      throw JSONParser.Error.UnexpectedCharacter(lineNumber: lineNumber, characterNumber: charNumber)
    }
    
    let sign = isNegative ? -1: 1
    if hasDecimal || hasExponent {
      divisor /= 10
      var number = Double(sign) * (Double(integer) + (Double(decimal) / divisor))
      if hasExponent {
        if positiveExponent {
          for _ in 1...exponent {
            number *= Double(10)
          }
        } else {
          for _ in 1...exponent {
            number /= Double(10)
          }
        }
      }
      return JSON.double(number)
    } else {
      var number: Int64
      if isNegative {
        if integer > UInt64(Int64.max) + 1 {
          throw JSONParser.Error.InvalidNumber(lineNumber: lineNumAtStart, characterNumber: charNumAtStart)
        } else if integer == UInt64(Int64.max) + 1 {
          number = Int64.min
        } else {
          number = Int64(integer) * -1
        }
      } else {
        if integer > UInt64(Int64.max) {
          throw JSONParser.Error.InvalidNumber(lineNumber: lineNumAtStart, characterNumber: charNumAtStart)
        } else {
          number = Int64(integer)
        }
      }
      return JSON.integer(Int64(number))
    }
  }
  
  func nextBool() throws -> JSON {
    var expectedWord: [UnicodeScalar]
    var expectedBool: Bool
    let lineNumAtStart = lineNumber
    let charNumAtStart = charNumber
    if scalar == trueToken[0] {
      expectedWord = trueToken
      expectedBool = true
    } else if scalar == falseToken[0] {
      expectedWord = falseToken
      expectedBool = false
    } else {
      throw JSONParser.Error.UnexpectedCharacter(lineNumber: lineNumber, characterNumber: charNumber)
    }
    do {
      let word = try [scalar] + nextScalars(UInt(expectedWord.count - 1))
      if word != expectedWord {
        throw JSONParser.Error.UnexpectedKeyword(lineNumber: lineNumAtStart, characterNumber: charNumAtStart)
      }
    } catch JSONParser.Error.EndOfFile {
      throw JSONParser.Error.UnexpectedKeyword(lineNumber: lineNumAtStart, characterNumber: charNumAtStart)
    }
    return JSON.bool(expectedBool)
  }
  
  func nextNull() throws -> JSON {
    let word = try [scalar] + nextScalars(3)
    if word != nullToken {
      throw JSONParser.Error.UnexpectedKeyword(lineNumber: lineNumber, characterNumber: charNumber-4)
    }
    return JSON.null
  }
}
