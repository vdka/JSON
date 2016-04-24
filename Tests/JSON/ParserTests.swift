
  func testParseNumber() {
    
    expect("21", toEqual: 21, afterApplying: VDKAParser.parseNumber)
    expect("1", toEqual: 1, afterApplying: VDKAParser.parseNumber)
    expect("-1", toEqual: -1, afterApplying: VDKAParser.parseNumber)
    expect("1e-1", toEqual: 0.1, afterApplying: VDKAParser.parseNumber)
    expect("-1e-1", toEqual: -0.1, afterApplying: VDKAParser.parseNumber)
    expect("-000000001", toEqual: -1, afterApplying: VDKAParser.parseNumber)
    expect("-1e000000001", toEqual: -10.0, afterApplying: VDKAParser.parseNumber)
    expect("12345.6789e01", toEqual: 123456.789, afterApplying: VDKAParser.parseNumber)
    expect("-12345.6789e-01", toEqual: -1234.56789, afterApplying: VDKAParser.parseNumber)
    
  }
  
  func testParseString() {
    
    expect(surrounding("🇦🇺"), toEqual: "🇦🇺", afterApplying: VDKAParser.parseString)
    expect(surrounding("vdka"), toEqual: "vdka", afterApplying: VDKAParser.parseString)
    expect(surrounding(""), toEqual: "", afterApplying: VDKAParser.parseString)
    expect(surrounding(" \\ "), toEqual: " \\ ", afterApplying: VDKAParser.parseString)
    expect(surrounding("\\\""), toEqual: "\\\"", afterApplying: VDKAParser.parseString)
    expect(surrounding("\\\"\t\r\n\n"), toEqual: "\\\"\t\r\n\n", afterApplying: VDKAParser.parseString)
    
  }
  
  func testParseValue() {
    
    expect("null", toEqual: JSON.null, afterApplying: VDKAParser.parseValue)
    expect("true", toEqual: true, afterApplying: VDKAParser.parseValue)
    expect("false", toEqual: false, afterApplying: VDKAParser.parseValue)
    
  }
  
  func testParseObject() {
    
    expect("{}", toEqual: [:], afterApplying: VDKAParser.parseObject)
    expect("{\"key\": 321}", toEqual: ["key": 321], afterApplying: VDKAParser.parseObject)
    expect("{\"key\": 321, \"key2\": true}", toEqual: ["key": 321, "key2": true], afterApplying: VDKAParser.parseObject)
    expect("{ \"key\" : 321 , \"key2\" : true }", toEqual: ["key": 321, "key2": true], afterApplying: VDKAParser.parseObject)
  }
  
  func testParseArray() {
    expect("[]", toEqual: [], afterApplying: VDKAParser.parseArray)
    expect("[1, 2, 3, 4]", toEqual: [1, 2, 3, 4], afterApplying: VDKAParser.parseArray)
    expect("[true, false, \"abc\", 4, 5.0]", toEqual: [true, false, "abc", 4, 5.0], afterApplying: VDKAParser.parseArray)
  }
  
}
