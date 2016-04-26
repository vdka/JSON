//
//  Shared.swift
//  JSONBench
//
//  Created by Ethan Jackwitz on 4/26/16.
//  Copyright © 2016 Ethan Jackwitz. All rights reserved.
//

import Foundation
import JSON

class Foo {}

public let jsonString: String = {
  let bundle = NSBundle(forClass: Foo.self)
  let path = bundle.pathForResource("test", ofType: "json")
  let data = NSData(contentsOfFile: path!)!
  let jsonString = String.fromCString(unsafeBitCast(data.bytes, UnsafePointer<CChar>.self))!
  
  return jsonString
}()

public let json: JSON = {
  let bundle = NSBundle(forClass: Foo.self)
  let path = bundle.pathForResource("test", ofType: "json")
  let data = NSData(contentsOfFile: path!)!
  let jsonString = String.fromCString(unsafeBitCast(data.bytes, UnsafePointer<CChar>.self))!
  
  return try! JSON.Parser.parse(jsonString)
}()

import JSON

public typealias VDKAJSON = JSON
