

// MARK: - JSON.Parser

// json special characters
let arrayOpen: UTF8.CodeUnit = "[".utf8.first!
let objectOpen: UTF8.CodeUnit = "{".utf8.first!
let arrayClose: UTF8.CodeUnit = "]".utf8.first!
let objectClose: UTF8.CodeUnit = "}".utf8.first!
let comma: UTF8.CodeUnit = ",".utf8.first!
let colon: UTF8.CodeUnit = ":".utf8.first!
let quote: UTF8.CodeUnit = "\"".utf8.first!
let backslash: UTF8.CodeUnit = "\\".utf8.first!

// whitespace characters
let space: UTF8.CodeUnit = " ".utf8.first!
let tab: UTF8.CodeUnit = "\t".utf8.first!
let cr: UTF8.CodeUnit = "\r".utf8.first!
let newline: UTF8.CodeUnit = "\n".utf8.first!

// Literal characters
let n: UTF8.CodeUnit = "n".utf8.first!
let t: UTF8.CodeUnit = "t".utf8.first!
let r: UTF8.CodeUnit = "r".utf8.first!
let u: UTF8.CodeUnit = "u".utf8.first!
let f: UTF8.CodeUnit = "f".utf8.first!
let a: UTF8.CodeUnit = "a".utf8.first!
let l: UTF8.CodeUnit = "l".utf8.first!
let s: UTF8.CodeUnit = "s".utf8.first!
let e: UTF8.CodeUnit = "e".utf8.first!

// Number characters
let zero: UTF8.CodeUnit = "0".utf8.first!
let minus: UTF8.CodeUnit = "-".utf8.first!
let numbers: Range<UTF8.CodeUnit> = "0".utf8.first!..."9".utf8.first!
let decimal: UTF8.CodeUnit = ".".utf8.first!
let E: UTF8.CodeUnit = "E".utf8.first!

// End of here Literals
let rue: [UTF8.CodeUnit] = ["r".utf8.first!, "u".utf8.first!, "e".utf8.first!]
let alse: [UTF8.CodeUnit] = ["a".utf8.first!, "l".utf8.first!, "s".utf8.first!, "e".utf8.first!]
let ull: [UTF8.CodeUnit] = ["u".utf8.first!, "l".utf8.first!, "l".utf8.first!]

extension JSON {
  
  public struct Parser {
    
    public struct Option: OptionSetType {
      public init(rawValue: UInt8) { self.rawValue = rawValue }
      public let rawValue: UInt8
      
      /// Do not remove null values from the resulting JSON value. Instead store `JSON.null`
      public static let noSkipNull = Option(rawValue: 1 << 1)
    }
    
    init(string: String, options: [Option] = []) {
      self.string = string
      
      self.scalars = Array(string.utf8)
      self.scalars.append(0) // Null terminated back to days of ye olde C
      
      self.buffer = UnsafeMutableBufferPointer(start: &scalars, count: scalars.count)
      
      self.pointer = buffer.baseAddress
      
      self.skipNull = !options.contains(.noSkipNull)
    }
    
    let skipNull: Bool
    var string: String
    var scalars: [UTF8.CodeUnit]
    var pointer: UnsafeMutablePointer<UTF8.CodeUnit>
    var buffer: UnsafeMutableBufferPointer<UTF8.CodeUnit>
  }
}


// MARK: - External API

extension JSON.Parser {
  
  public static func parse(string: String, options: [Option] = []) throws -> JSON {
    
    var parser = self.init(string: string, options: options)
    do {
      
      return try parser.parseValue()
      
    } catch let code as ErrorCode {
      // TODO: Make this work, or DEPRECATE it.
      
      let charsIn = parser.scalars.count - parser.buffer.count
      print("Parsed up to: \n\(parser.scalars[0..<charsIn].map({ String($0) }).joinWithSeparator(""))")
      var line: UInt = 0
      var char: UInt = 0
      for ch in parser.scalars.prefix(charsIn) {
        switch ch {
        case newline:
          line += 1
          char  = 0
          
        default:
          char += 1
        }
      }
      throw Error(char: char, line: line, code: code)
    }
  }
}


// MARK: - Internals

extension JSON.Parser {
  func peek() -> UTF8.CodeUnit {
    return pointer.memory
  }
  
  mutating func pop() throws -> UTF8.CodeUnit {
    guard pointer.memory != 0 else { throw ErrorCode.endOfStream }
    defer { pointer = pointer.advancedBy(1) }
    return pointer.memory
  }
  
  /// Skips null pointer check. Use should occur only after checking the result of peek()
  mutating func unsafePop() -> UTF8.CodeUnit {
    defer { pointer = pointer.advancedBy(1) }
    return pointer.memory
  }
}

extension JSON.Parser {
  mutating func skipWhitespace() {
    repeat {
      switch peek() {
      case space, tab, cr, newline:
        unsafePop()
      default: return
      }
    } while true
  }
  
}

extension JSON.Parser {
  
  /**
   - precondition: `pointer` is at the beginning of a literal
   - postcondition: `pointer` will be in the next non-`whiteSpace` position
  */
  mutating func parseValue() throws -> JSON {
    
    assert(![space, tab, cr, newline, 0].contains(pointer.memory))
    
    defer { skipWhitespace() }
    switch peek() {
    case objectOpen:
      let o = try parseObject()
      return o
      
    case arrayOpen:
      let a = try parseArray()
      return a
      
    case quote:
      let s = try parseString()
      return .string(s)
      
    case minus, numbers:
      let num = try parseNumber()
      return num
      
    case f:
      unsafePop()
      try assertFollowedBy(alse)
      return .bool(false)
      
    case t:
      unsafePop()
      try assertFollowedBy(rue)
      return .bool(true)
      
    case n:
      unsafePop()
      try assertFollowedBy(ull)
      return .null
      
    default:
      // NOTE: This could occur if we failed to skipWhitespace somewhere
      throw ErrorCode.invalidSyntax
    }
      
  }
  
  mutating func parseArray() throws -> JSON {
    assert(peek() == arrayOpen)
    unsafePop()
    
    skipWhitespace()
    
    guard peek() != arrayClose else {
      unsafePop()
      return .array([])
    }
    
    var tempArray: [JSON] = []
    
    repeat {
      
      switch peek() {
      case comma:
        unsafePop()
        skipWhitespace()
        
      case arrayClose:
        unsafePop()
        return .array(tempArray)
        
      default:
        let value = try parseValue()
        switch value {
        case .null where skipNull: break
        default: tempArray.append(value)
        }
        
      }
    } while true
  }
  
  mutating func parseObject() throws -> JSON {
    
    assert(peek() == objectOpen)
    unsafePop()
    
    skipWhitespace()
    
    guard peek() != objectClose else {
      unsafePop()
      return .object([])
    }
    var tempDict: [(String, JSON)] = []
    tempDict.reserveCapacity(6)
    
    repeat {
      switch peek() {
      case quote:
        let key = try parseString()
        try skipColon()
        let value = try parseValue()
        
        switch value {
        case .null where skipNull: break
        default: tempDict.append( (key, value) )
        }
        
      case comma:
        unsafePop()
        skipWhitespace()
        
      case objectClose:
        unsafePop()
        return .object(tempDict)
        
      default:
        throw ErrorCode.invalidSyntax
      }
    } while true
  }
  
  mutating func assertFollowedBy(chars: [UTF8.CodeUnit]) throws {
    for scalar in chars {
      guard try scalar == pop() else { throw ErrorCode.invalidLiteral }
    }
  }
  
  mutating func parseString() throws -> String {
    
    assert(peek() == quote)
    unsafePop()
    
    let startAddress = pointer
    
    repeat {
      // TODO: Check if we can [point|copy] the memory directly (memcpy)
      let char = try pop()
      if char == quote && pointer.advancedBy(-2).memory != backslash {
        pointer.advancedBy(-1).memory = 0
        return String.fromCString(unsafeBitCast(startAddress, UnsafePointer<CChar>.self))!
      }
    } while true
  }
  
  mutating func parseNumber() throws -> JSON {
    assert(numbers ~= peek() || minus == peek())
    
    var seenExponent = false
    var seenDecimal = false
    
    let negative: Bool = {
      guard minus == peek() else { return false }
      unsafePop()
      return true
    }()
    
    var significand: UInt64 = 0
    var mantisa: UInt64 = 0
    var divisor: Double = 10
    var exponent: UInt64 = 0
    var negativeExponent = false
    var overflow: Bool
    
    repeat {
      switch peek() {
      case numbers where !seenExponent && !seenDecimal:
        
        (significand, overflow) = UInt64.multiplyWithOverflow(significand, 10)
        guard !overflow else { throw JSON.Parser.ErrorCode.numberOverflow }
        
        (significand, overflow) = UInt64.addWithOverflow(significand, UInt64(unsafePop() - zero))
        guard !overflow else { throw JSON.Parser.ErrorCode.numberOverflow }
        
        // naive solution. Ignores overflows
//        significand *= 10
//        significand += UInt64(unsafePop() - zero) // unsafePop() returns a UTF8.CodeUnit and `zero` is the UTF8.CodeUnit for '0'
        
      case numbers where seenDecimal && !seenExponent: // decimals must come before exponents
        divisor *= 10
        
        (mantisa, overflow) = UInt64.multiplyWithOverflow(mantisa, 10)
        guard !overflow else { throw JSON.Parser.ErrorCode.numberOverflow }
        
        (mantisa, overflow) = UInt64.addWithOverflow(mantisa, UInt64(unsafePop() - zero))
        guard !overflow else { throw JSON.Parser.ErrorCode.numberOverflow }
        
        // naive solution. Ignores overflows
//        mantisa *= 10
//        mantisa += UInt64(unsafePop() - zero)
        
      case numbers where seenExponent:
        
        (exponent, overflow) = UInt64.multiplyWithOverflow(exponent, 10)
        guard !overflow else { throw JSON.Parser.ErrorCode.numberOverflow }
        
        (exponent, overflow) = UInt64.addWithOverflow(exponent, UInt64(unsafePop() - zero))
        guard !overflow else { throw JSON.Parser.ErrorCode.numberOverflow }
        
        // naive solution. Ignores overflows
//        exponent *= 10
//        exponent += UInt64(unsafePop() - zero)
        
      case decimal where !seenExponent && !seenDecimal:
        unsafePop() // remove the decimal
        seenDecimal = true
        
      case E, e where !seenExponent:
        unsafePop() // remove the 'e' || 'E'
        seenExponent = true
        if peek() == minus {
          negativeExponent = true
          unsafePop() // remove the '-'
        }
        
        
      // is end of number
        
      case arrayClose, objectClose, comma, space, tab, cr, newline, 0:
        
        switch (seenDecimal, seenExponent) {
        case (false, false):
          
          if negative && significand == UInt64(Int64.max) + 1 {
            return .integer(Int64.min)
          } else if significand > UInt64(Int64.max) {
            throw JSON.Parser.ErrorCode.numberOverflow
          }
          
          return .integer(negative ? -Int64(significand) : Int64(significand))
          
        case (true, false):
          
          let n = Double(significand) + Double(mantisa) / (divisor / 10)
          return .double(negative ? -n : n)
          
        case (false, true):
          
          let n = Double(significand)
            .power(10, exponent: exponent, isNegative: negativeExponent)
          
          return .double(negative ? -n : n)
          
        case (true, true):
          
          let n = (Double(significand) + Double(mantisa) / (divisor / 10))
            .power(10, exponent: exponent, isNegative: negativeExponent)
          
          return .double(negative ? -n : n)
          
        }
        
      default: throw JSON.Parser.ErrorCode.invalidNumber
      }
      
    } while true
    
  }
}


// MARK: - Internal internals. could be nested functions if it didnt screw with debugger.

extension JSON.Parser {
  
  mutating func skipColon() throws {
    skipWhitespace()
    guard case colon = try pop() else {
      throw ErrorCode.missingColon
    }
    skipWhitespace()
  }
}

extension JSON.Parser {
  
  public struct Error: ErrorType {
    let char: UInt
    let line: UInt
    let code: ErrorCode
  }
  
  public enum ErrorCode: String, ErrorType {
    case missingColon
    case trailingComma
    case expectedColon
    case invalidSyntax
    case invalidNumber
    case numberOverflow
    case invalidLiteral
    case invalidUnicode
    case endOfStream
  }
}

extension JSON.Parser.Error: CustomStringConvertible {
  public var description: String {
    return "\(code) @ ln: \(line), col: \(char)"
  }
}

extension Double {
  internal func power<I: IntegerType>(base: Double, exponent: I, isNegative: Bool) -> Double {
    var a: Double = self
    if isNegative {
      for _ in 0..<exponent { a /= base }
    } else {
      for _ in 0..<exponent { a *= base }
    }
    return a
  }
}
