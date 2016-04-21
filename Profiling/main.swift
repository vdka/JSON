//
//  main.swift
//  Profiling
//
//  Created by Ethan Jackwitz on 4/20/16.
//  Copyright © 2016 Ethan Jackwitz. All rights reserved.
//

import Foundation

let json: JSON = {
  print("Generating jsonString")
  
  let numElements = 100_000
  let arc4random_max = 0x100000000
  
  func randomNumber() -> Double { return Double(arc4random()) / Double(arc4random_max) }
  
  func randomName() -> String {
    var str = ""
    let chars = Array("abcdefghijklmnopqrstuvwxyz".characters)
    for _ in 0...5 {
      let char = chars[Int(arc4random_uniform(UInt32(chars.count)))]
      str.append(char)
    }
    str.appendContentsOf(" ")
    str.appendContentsOf(arc4random_uniform(10000).description)
    return str
  }
  
  var arr: [JSON] = []
  
  for _ in 0..<numElements {
    arr.append(
      [
        "x": randomNumber(),
        "y": randomNumber(),
        "z": randomNumber(),
        "name": randomName(),
        "opts": [
          "1": [1, true] as JSON
          ] as JSON
        ] as JSON
    )
  }
  print("Done generating jsonString")
  
  return ["coordinates": arr.encoded(), "info": "some info"]
}()

let jsonString = try! JSON.Serializer.serialize(json)
//let jsonString = try! json.serialized(options: [.prettyPrint])

try! VDKAParser.parse(jsonString)

//try! JSON.serialize(json)

print("done")
