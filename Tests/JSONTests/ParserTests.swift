
import XCTest
@testable import JSON

class ParsingTests: XCTestCase {

  func test_FailOnEmpty() {

    expect("", toThrowWithReason: .emptyStream)
  }

  func test_CompletelyWrong() {

    expect("<XML>", toThrowWithReason: .invalidSyntax)
  }

  func testExtraTokensThrow() {

    expect("{'hello':'world'} blah", toThrowWithReason: .invalidSyntax)
  }


  // MARK: - Null

  func testNullParses() {

    expect("null", toParseTo: .null)
  }

  func testNullThrowsOnMismatch() {

    expect("nall", toThrowWithReason: .invalidLiteral)
  }

  func testNullSkipInObject() {

    expect("{'key': null}", toParseTo: [:], withOptions: .omitNulls)
  }

  func testNullSkipInArray() {

    expect("['someString', true, null, 1]", toParseTo: ["someString", true, 1], withOptions: .omitNulls)
  }

  func testNullSkipFragment() {

    // not sure what to expect here. but so long as it's consistent.
    expect("null", toParseTo: .null, withOptions: [.omitNulls, .allowFragments])
  }

  func testFragmentNormallyThrows() {

    expect("'frag out'", toThrowWithReason: .fragmentedJson, withOptions: [])
  }


  // MARK: - Bools

  func testTrueParses() {

    expect("true", toParseTo: true)
  }

  func testTrueThrowsOnMismatch() {

    expect("tRue", toThrowWithReason: .invalidLiteral)
  }

  func testFalseParses() {

    expect("false", toParseTo: false)
  }

  func testBoolean_False_Mismatch() {

    expect("fals ", toThrowWithReason: .invalidLiteral)
  }


  // MARK: - Arrays

  func testArray_JustComma() {

    expect("[,]", toThrowWithReason: .invalidSyntax)
  }

  func testArray_JustNull() {

    expect("[ null ]", toParseTo: [JSON.null])
  }

  func testArray_ZeroBegining() {

    expect("[0, 1] ", toParseTo: [0, 1])
  }

  func testArray_ZeroBeginingWithWhitespace() {

    expect("[0            , 1] ", toParseTo: [0, 1])
  }

  func testArray_NullsBoolsNums_Normal_Minimal_RootParser() {

    expect("[null,true,false,12,-10,-24.3,18.2e9]", toParseTo:
      [JSON.null, true, false, 12, -10, -24.3, 18200000000.0]
    )
  }

  func testArray_NullsBoolsNums_Normal_MuchWhitespace() {

    expect(" \t[\n  null ,true, \n-12.3 , false\r\n]\n  ", toParseTo:
      [JSON.null, true, -12.3, false]
    )
  }

  func testArray_NullsAndBooleans_Bad_MissingEnd() {

    expect("[\n  null ,true, \nfalse\r\n\n  ", toThrowWithReason: .endOfStream)
  }

  func testArray_NullsAndBooleans_Bad_MissingComma() {

    expect("[\n  null true, \nfalse\r\n]\n  ", toThrowWithReason: .expectedComma)
  }

  func testArray_NullsAndBooleans_Bad_ExtraComma() {

    expect("[\n  null , , true, \nfalse\r\n]\n  ", toThrowWithReason: .invalidSyntax)
  }

  func testArray_NullsAndBooleans_Bad_TrailingComma() {

    expect("[\n  null ,true, \nfalse\r\n, ]\n  ", toThrowWithReason: .trailingComma)
  }


  // MARK: - Numbers

  func testNumber_Int_ZeroWithTrailingWhitespace() {

    expect("0 ", toParseTo: 0)
  }

  func testNumber_Int_Zero() {

    expect("0", toParseTo: 0)
  }

  func testNumber_Int_One() {

    expect("1", toParseTo: 1)
  }

  func testNumber_Int_Basic() {

    expect("24", toParseTo: 24)
  }

  func testNumber_IntMin() {

    expect(Int.min.description, toParseTo: .integer(Int64.min))
  }

  func testNumber_IntMax() {

    expect(Int.max.description, toParseTo: .integer(Int64.max))
  }

  func testNumber_Int_Negative() {

    expect("-32", toParseTo: -32)
  }

  func testNumber_Int_Garbled() {

    expect("42-4", toThrowWithReason: .invalidNumber)
  }

  func testNumber_Int_LeadingZero() {

    expect("007", toThrowWithReason: .invalidNumber)
  }

  func testNumber_Int_Overflow() {

    expect("9223372036854775808", toThrowWithReason: .numberOverflow)
    expect("18446744073709551616", toThrowWithReason: .numberOverflow)
    expect("18446744073709551616", toThrowWithReason: .numberOverflow)
  }


  func testNumber_Double_Overflow() {

    expect("18446744073709551616.0", toThrowWithReason: .numberOverflow)
    expect("1.18446744073709551616", toThrowWithReason: .numberOverflow)
    expect("1e18446744073709551616", toThrowWithReason: .numberOverflow)
    expect("184467440737095516106.0", toThrowWithReason: .numberOverflow)
    expect("1.184467440737095516106", toThrowWithReason: .numberOverflow)
    expect("1e184467440737095516106", toThrowWithReason: .numberOverflow)
  }

  func testNumber_Dbl_LeadingZero() {

    expect("006.123", toThrowWithReason: .invalidNumber)
  }

  func testNumber_Dbl_Basic() {

    expect("46.57", toParseTo: 46.57)
  }

  func testNumber_Dbl_ZeroSomething() {

    expect("0.98", toParseTo: 0.98)
  }

  func testNumber_Dbl_MinusZeroSomething() {

    expect("-0.98", toParseTo: -0.98)
  }

  func testNumber_Dbl_ThrowsOnMinus() {

    expect("-", toThrowWithReason: .invalidNumber)
  }

  func testNumber_Dbl_Incomplete() {

    expect("24.", toThrowWithReason: .invalidNumber)
  }

  func testNumber_Dbl_Negative() {

    expect("-24.34", toParseTo: -24.34)
  }

  func testNumber_Dbl_Negative_WrongChar() {

    expect("-24.3a4", toThrowWithReason: .invalidNumber)
  }

  func testNumber_Dbl_Negative_TwoDecimalPoints() {

    expect("-24.3.4", toThrowWithReason: .invalidNumber)
  }

  func testNumber_Dbl_Negative_TwoMinuses() {

    expect("--24.34", toThrowWithReason: .invalidNumber)
  }

  func testNumber_Double_Exp_Normal() {

    expect("-24.3245e2", toParseTo: -2432.45)
  }

  func testNumber_Double_Exp_Positive() {

    expect("-24.3245e+2", toParseTo: -2432.45)
  }

  // TODO (vdka): floating point accuracy
  // Potential to fix through using Darwin.C.pow but, isn't that a dependency?
  // Maybe reimplement C's gross lookup table pow method
  // http://opensource.apple.com/source/Libm/Libm-2026/Source/Intel/expf_logf_powf.c
  // http://opensource.apple.com/source/Libm/Libm-315/Source/ARM/powf.c
  // May be hard to do this fast and correct in pure swift.
  func testNumber_Double_Exp_Negative() {

    // FIXME (vdka): Fix floating point number types
    expect("-24.3245e-2", toParseTo: -24.3245e-2)
  }

  func testNumber_Double_ExactnessNoExponent() {

    expect("-123451123442342.12124234", toParseTo: -123451123442342.12124234)
  }

  func testNumber_Double_ExactnessWithExponent() {

    expect("-123456789.123456789e-150", toParseTo: -123456789.123456789e-150)
  }

  func testNumber_Double_Exp_NoFrac() {

    expect("24E2", toParseTo: 2400.0)
  }

  func testNumber_Double_Exp_TwoEs() {

    expect("-24.3245eE2", toThrowWithReason: .invalidNumber)
  }


  // MARK: - Strings & Unicode

  func testEscape_Solidus() {

    expect("'\\/'", toParseTo: "/")
  }

  func testLonelyReverseSolidus() {

    expect("'\\'", toThrowWithReason: .invalidEscape)
  }

  func testEscape_Unicode_Normal() {

    expect("'\\u0048'", toParseTo: "H")
  }

  func testEscape_Unicode_Invalid() {

    expect("'\\uD83d\\udQ24'", toThrowWithReason: .invalidEscape)
  }

  func testEscape_Unicode_Complex() {

    expect("'\\ud83d\\ude24'", toParseTo: "\u{1F624}")
  }

  func testEscape_Unicode_Complex_MixedCase() {

    expect("'\\uD83d\\udE24'", toParseTo: "\u{1F624}")
  }

  func testEscape_Unicode_InvalidUnicode_MissingDigit() {

    expect("'\\u048'", toThrowWithReason: .invalidEscape)
  }

  func testEscape_Unicode_InvalidUnicode_MissingAllDigits() {

    expect("'\\u'", toThrowWithReason: .invalidEscape)
  }

  func testString_Empty() {

    expect("''", toParseTo: "")
  }

  func testString_Normal() {

    expect("'hello world'", toParseTo: "hello world")
  }

  func testString_Normal_Backslashes() {

    // This looks insane and kinda is. The rule is the right side just halve, the left side quarter.
    expect("'C:\\\\\\\\share\\\\path\\\\file'", toParseTo: "C:\\\\share\\path\\file")
  }

  func testString_Normal_WhitespaceInside() {

    expect("'he \\r\\n l \\t l \\n o wo\\rrld '", toParseTo: "he \r\n l \t l \n o wo\rrld ")
  }

  func testString_StartEndWithSpaces() {

    expect("'  hello world  '", toParseTo: "  hello world  ")
  }

  func testString_Unicode_NoTrailingSurrogate() {

    expect("'\\ud83d'", toThrowWithReason: .endOfStream)
  }

  func testString_Unicode_InvalidTrailingSurrogate() {

    expect("'\\ud83d\\u0040'", toThrowWithReason: .invalidUnicode)
  }

  func testString_Unicode_RegularChar() {

    expect("'hel\\u006co world'", toParseTo: "hello world")
  }

  func testString_Unicode_SpecialCharacter_CoolA() {

    expect("'h\\u01cdw'", toParseTo: "hǍw")
  }

  func testString_Unicode_SpecialCharacter_HebrewShin() {

    expect("'h\\u05e9w'", toParseTo: "hשw")
  }

  func testString_Unicode_SpecialCharacter_QuarterTo() {

    expect("'h\\u25d5w'", toParseTo: "h◕w")
  }

  func testString_Unicode_SpecialCharacter_EmojiSimple() {

    expect("'h\\ud83d\\ude3bw'", toParseTo: "h😻w")
  }

  func testString_Unicode_SpecialCharacter_EmojiComplex() {

    expect("'h\\ud83c\\udde8\\ud83c\\uddffw'", toParseTo: "h🇨🇿w")
  }

  func testString_SpecialCharacter_QuarterTo() {

    expect("'h◕w'", toParseTo: "h◕w")
  }

  func testString_SpecialCharacter_EmojiSimple() {

    expect("'h😻w'", toParseTo: "h😻w")
  }

  func testString_SpecialCharacter_EmojiComplex() {

    expect("'h🇨🇿w'", toParseTo: "h🇨🇿w")
  }

  func testString_BackspaceEscape() {

    let backspace = Character(UnicodeScalar(0x08))

    expect("'\\b'", toParseTo: String(backspace).encoded())
  }

  func testEscape_FormFeed() {

    let formfeed = Character(UnicodeScalar(0x0C))

    expect("'\\f'", toParseTo: String(formfeed).encoded())

  }

  func testString_ContainingEscapedQuotes() {

    expect("'\\\"\\\"'", toParseTo: "\"\"")
  }

  func testString_ContainingSlash() {

    expect("'http:\\/\\/example.com'", toParseTo: "http://example.com")
  }

  func testString_ContainingInvalidEscape() {

    expect("'\\a'", toThrowWithReason: .invalidEscape)
  }


  // MARK: - Objects

  func testObject_Empty() {

    expect("{}", toParseTo: [:])
  }

  func testObject_JustComma() {

    expect("{,}", toThrowWithReason: .trailingComma)
  }

  func testObject_SyntaxError() {

    expect("{'hello': 'failure'; 'goodbye': true}", toThrowWithReason: .invalidSyntax)
  }

  func testObject_TrailingComma() {

    expect("{'someKey': true,,}", toThrowWithReason: .trailingComma)
  }

  func testObject_MissingComma() {

    expect("{'someKey': true 'someOther': false}", toThrowWithReason: .expectedComma)
  }

  func testObject_MissingColon() {

    expect("{'someKey' true}", toThrowWithReason: .expectedColon)
  }

  func testObject_Example1() {
    expect("{\t'hello': 'wor🇨🇿ld', \n\t 'val': 1234, 'many': [\n-12.32, null, 'yo'\r], 'emptyDict': {}, 'dict': {'arr':[]}, 'name': true}", toParseTo:
      [
        "hello": "wor🇨🇿ld",
        "val": 1234,
        "many": [-12.32, JSON.null, "yo"] as JSON,
        "emptyDict": [:] as JSON,
        "dict": ["arr": [] as JSON] as JSON,
        "name": true
      ]
    )
  }

  // NOTE(vdka): Need to add special handling for this.
  func testTrollBlockComment() {

    expect("/*/ {'key':'harry'}", toThrowWithReason: .invalidSyntax, withOptions: .allowComments)
  }

  func testLineComment_start() {

    expect("// This is a comment\n{'key':true}", toParseTo: ["key": true], withOptions: .allowComments)
  }


  func testLineComment_endWithNewline() {

    expect("// This is a comment\n{'key':true}", toParseTo: ["key": true], withOptions: .allowComments)
    expect("{'key':true}// This is a comment\n", toParseTo: ["key": true], withOptions: .allowComments)
  }

  func testLineComment_end() {

    expect("{'key':true}// This is a comment", toParseTo: ["key": true], withOptions: .allowComments)
    expect("{'key':true}\n// This is a comment", toParseTo: ["key": true], withOptions: .allowComments)
  }

  func testBlockComment_start() {

    expect("/* This is a comment */{'key':true}", toParseTo: ["key": true], withOptions: .allowComments)
  }

  func testBlockComment_end() {

    expect("{'key':true}/* This is a comment */", toParseTo: ["key": true], withOptions: .allowComments)
    expect("{'key':true}\n/* This is a comment */", toParseTo: ["key": true], withOptions: .allowComments)
  }

  func testBlockCommentNested() {

    expect("[true]/* a /* b */ /* c */ d */", toParseTo: [true], withOptions: .allowComments)
  }

  func testDetailedError() {

    expect("0xbadf00d", toThrowAtByteOffset: 0, withReason: .invalidNumber)
    expect("false blah", toThrowAtByteOffset: 6, withReason: .invalidSyntax)
  }
}

extension ParsingTests {

  func expect(_ input: String, toThrowWithReason expectedError: JSON.Parser.Error.Reason, withOptions options: JSON.Parser.Option = [.allowFragments],
              file: StaticString = #file, line: UInt = #line) {

    let input = input.replacingOccurrences(of: "'", with: "\"")

    let data = Array(input.utf8)

    do {

      let val = try JSON.Parser.parse(data, options: options)

      XCTFail("expected to throw \(expectedError) but got \(val)", file: file, line: line)
    } catch let error as JSON.Parser.Error {

      XCTAssertEqual(error.reason, expectedError, file: file, line: line)
    } catch {

      XCTFail("expected to throw \(expectedError) but got a different error type!.")
    }
  }

  func expect(_ input: String, toThrowAtByteOffset expectedOffset: Int, withReason expectedReason: JSON.Parser.Error.Reason,
              withOptions options: JSON.Parser.Option = [.allowFragments],
              file: StaticString = #file, line: UInt = #line) {

    let input = input.replacingOccurrences(of: "'", with: "\"")

    let data = Array(input.utf8)

    do {

      let val = try JSON.Parser.parse(data, options: options)

      XCTFail("expected to throw with reason \(expectedReason) but got \(val)", file: file, line: line)
    } catch let error as JSON.Parser.Error {


      XCTAssertEqual(error.byteOffset, expectedOffset, file: file, line: line)
    } catch {

      XCTFail("expected to throw JSON.Parser.Error but got a different error type!.")
    }
  }

  func expect(_ input: String, toParseTo expected: JSON, withOptions options: JSON.Parser.Option = [.allowFragments],
              file: StaticString = #file, line: UInt = #line) {

    let input = input.replacingOccurrences(of: "'", with: "\"")

    let data = Array(input.utf8)

    do {
      let output = try JSON.Parser.parse(data, options: options)

      XCTAssertEqual(output, expected, file: file, line: line)
    } catch {
      XCTFail("\(error)", file: file, line: line)
    }
  }
}

#if os(Linux)
  extension ParsingTests {
    static var allTests : [(String, (ParsingTests) -> () throws -> Void)] {
      return [
        ("test_FailOnEmpty", testPrepareForReading_FailOnEmpty),
        ("testExtraTokensThrow", testExtraTokensThrow),
        ("testNullParses", testNullParses),
        ("testNullThrowsOnMismatch", testNullThrowsOnMismatch),
        ("testTrueParses", testTrueParses),
        ("testTrueThrowsOnMismatch", testTrueThrowsOnMismatch),
        ("testFalseParses", testFalseParses),
        ("testBoolean_False_Mismatch", testBoolean_False_Mismatch),
        ("testArray_NullsBoolsNums_Normal_Minimal_RootParser", testArray_NullsBoolsNums_Normal_Minimal_RootParser),
        ("testArray_NullsBoolsNums_Normal_MuchWhitespace", testArray_NullsBoolsNums_Normal_MuchWhitespace),
        ("testArray_NullsAndBooleans_Bad_MissingEnd", testArray_NullsAndBooleans_Bad_MissingEnd),
        ("testArray_NullsAndBooleans_Bad_MissingComma", testArray_NullsAndBooleans_Bad_MissingComma),
        ("testArray_NullsAndBooleans_Bad_ExtraComma", testArray_NullsAndBooleans_Bad_ExtraComma),
        ("testArray_NullsAndBooleans_Bad_TrailingComma", testArray_NullsAndBooleans_Bad_TrailingComma),
        ("testNumber_Int_Zero", testNumber_Int_Zero),
        ("testNumber_Int_One", testNumber_Int_One),
        ("testNumber_Int_Basic", testNumber_Int_Basic),
        ("testNumber_Int_Negative", testNumber_Int_Negative),
        ("testNumber_Dbl_Basic", testNumber_Dbl_Basic),
        ("testNumber_Dbl_ZeroSomething", testNumber_Dbl_ZeroSomething),
        ("testNumber_Dbl_MinusZeroSomething", testNumber_Dbl_MinusZeroSomething),
        ("testNumber_Dbl_Incomplete", testNumber_Dbl_Incomplete),
        ("testNumber_Dbl_Negative", testNumber_Dbl_Negative),
        ("testNumber_Dbl_Negative_WrongChar", testNumber_Dbl_Negative_WrongChar),
        ("testNumber_Dbl_Negative_TwoDecimalPoints", testNumber_Dbl_Negative_TwoDecimalPoints),
        ("testNumber_Dbl_Negative_TwoMinuses", testNumber_Dbl_Negative_TwoMinuses),
        ("testNumber_Double_Exp_Normal", testNumber_Double_Exp_Normal),
        ("testNumber_Double_Exp_Positive", testNumber_Double_Exp_Positive),
        ("testNumber_Double_Exp_Negative", testNumber_Double_Exp_Negative),
        ("testNumber_Double_Exp_NoFrac", testNumber_Double_Exp_NoFrac),
        ("testNumber_Double_Exp_TwoEs", testNumber_Double_Exp_TwoEs),
        ("testEscape_Unicode_Normal", testEscape_Unicode_Normal),
        ("testEscape_Unicode_InvalidUnicode_MissingDigit", testEscape_Unicode_InvalidUnicode_MissingDigit),
        ("testEscape_Unicode_InvalidUnicode_MissingAllDigits", testEscape_Unicode_InvalidUnicode_MissingAllDigits),
        ("testString_Empty", testString_Empty),
        ("testString_Normal", testString_Normal),
        ("testString_Normal_WhitespaceInside", testString_Normal_WhitespaceInside),
        ("testString_StartEndWithSpaces", testString_StartEndWithSpaces),
        ("testString_Unicode_RegularChar", testString_Unicode_RegularChar),
        ("testString_Unicode_SpecialCharacter_CoolA", testString_Unicode_SpecialCharacter_CoolA),
        ("testString_Unicode_SpecialCharacter_HebrewShin", testString_Unicode_SpecialCharacter_HebrewShin),
        ("testString_Unicode_SpecialCharacter_QuarterTo", testString_Unicode_SpecialCharacter_QuarterTo),
        ("testString_Unicode_SpecialCharacter_EmojiSimple", testString_Unicode_SpecialCharacter_EmojiSimple),
        ("testString_Unicode_SpecialCharacter_EmojiComplex", testString_Unicode_SpecialCharacter_EmojiComplex),
        ("testString_SpecialCharacter_QuarterTo", testString_SpecialCharacter_QuarterTo),
        ("testString_SpecialCharacter_EmojiSimple", testString_SpecialCharacter_EmojiSimple),
        ("testString_SpecialCharacter_EmojiComplex", testString_SpecialCharacter_EmojiComplex),
        ("testObject_Empty", testObject_Empty),
        ("testObject_Example1", testObject_Example1),
        ("testDetailedError", testDetailedError),
      ]
    }
  }
#endif
