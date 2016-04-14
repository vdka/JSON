//
//  JSONCore.swift
//  JSONCore
//
//  Created by Tyrone Trevorrow on 23/10/2015.
//  Copyright © 2015 Tyrone Trevorrow. All rights reserved.
//

// TODO: Copyright permissions.

/// Any value that can be expressed in JSON has a representation in `JSON`.
public enum JSON {
  case object([String: JSON])
  case array([JSON])
  case null
  case bool(Bool)
  case string(String)
  case integer(Int64)
  case double(Double)
}


// MARK: - JSON: CustomStringConvertible

extension JSON: CustomStringConvertible {
  public var description: String {
    return (try? self.serialized(options: [.prettyPrint])) ?? "invalid json"
  }
}


// MARK: - JSON Equatable conformance

extension JSON: Equatable {}
public func ==(lhs: JSON, rhs: JSON) -> Bool {
  switch (lhs, rhs) {
  case (.null, .null): return true
  case (.bool(let l), .bool(let r)): return l == r
  case (.array(let l), .array(let r)): return l == r
  case (.string(let l), .string(let r)): return l == r
  case (.object(let l), .object(let r)): return l == r
  case (.double(let l), .double(let r)): return l == r
  case (.integer(let l), .integer(let r)): return l == r
    
  default: return false
  }
}


// MARK: - JSON LiteralConvertible conformance

extension JSON: ArrayLiteralConvertible {
  public init(arrayLiteral elements: JSONEncodable...) {
    self = .array(elements.map(JSON.init))
  }
}

extension JSON: DictionaryLiteralConvertible {
  public init(dictionaryLiteral elements: (String, JSONEncodable)...) {
    var dict: [String: JSON] = [:]
    for (k, v) in elements {
      dict[k] = v.encoded()
    }
    
    self = .object(dict)
  }
}

extension JSON: IntegerLiteralConvertible {
  public init(integerLiteral value: IntegerLiteralType) {
    let val = Int64(value)
    self = .integer(val)
  }
}

extension JSON: FloatLiteralConvertible {
  public init(floatLiteral value: FloatLiteralType) {
    let val = Double(value)
    self = .double(val)
  }
}

extension JSON: StringLiteralConvertible {
  public init(stringLiteral value: String) {
    self = .string(value)
  }
  
  public init(extendedGraphemeClusterLiteral value: String) {
    self = .string(value)
  }
  
  public init(unicodeScalarLiteral value: String) {
    self = .string(value)
  }
}

extension JSON: NilLiteralConvertible {
  public init(nilLiteral: ()) {
    self = .null
  }
}

extension JSON: BooleanLiteralConvertible {
  public init(booleanLiteral value: Bool) {
    self = .bool(value)
  }
}

