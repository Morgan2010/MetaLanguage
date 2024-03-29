//
//  File.swift
//  File
//
//  Created by Morgan McColl on 9/10/21.
//

import Foundation
import XCTest
@testable import MetaLanguage 

final class TestTests: XCTestCase {
    
    var testData: String?
    
    var nestedTest: String?
    
    override func setUp() {
        testData = "    @swift test trueTest {\n        XCTAssertTrue(true)\n    }"
        nestedTest = "    @swift test nestedTest {\n        [0, 1, 2].enumerated.forEach {\n        XCTAssertEqual($0.0, $0.1)\n    }\n    }"
    }
    
    func testCreatesValidTest() {
        let test = Test(rawValue: testData!)
        let expected: Test = .languageTest(name: "test_trueTest", code: "XCTAssertTrue(true)", language: .swift)
        XCTAssertNotNil(test)
        TestTests.compareTest(uut: test, expected: expected)
    }
    
    func testCreateValidNestedTest() {
        let expected: Test = .languageTest(name: "test_nestedTest", code: "[0, 1, 2].enumerated.forEach {\n    XCTAssertEqual($0.0, $0.1)\n    }", language: .swift)
        let test = Test(rawValue: nestedTest!)
        XCTAssertNotNil(test)
        TestTests.compareTest(uut: test, expected: expected)
    }

    func testDescription() {
        let expected = "@swift test test_trueTest " + "XCTAssertTrue(true)".createBlock
        let test = Test(rawValue: testData!)
        XCTAssertNotNil(test)
        XCTAssertEqual(test!.description, expected)
    }
    
    static func compareTest(uut: Test?, expected: Test) {
        if uut == nil {
            XCTAssertTrue(false)
            return
        }
        switch uut! {
        case .languageTest(let name, let code, let language):
            switch expected {
            case .languageTest(let expectedName, let expectedCode, let expectedLanguage):
                XCTAssertEqual(name.trimmingCharacters(in: .whitespacesAndNewlines), expectedName.trimmingCharacters(in: .whitespacesAndNewlines))
                XCTAssertEqual(language, expectedLanguage)
                let codeLines = code.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: .newlines)
                let expectedCodeLines = expectedCode.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: .newlines)
                guard codeLines.count == expectedCodeLines.count else {
                    XCTAssertTrue(false)
                    return
                }
                codeLines.indices.forEach {
                    XCTAssertEqual(codeLines[$0].trimmingCharacters(in: .whitespacesAndNewlines), expectedCodeLines[$0].trimmingCharacters(in: .whitespacesAndNewlines))
                }
            default:
                XCTAssertTrue(false)
            }
        default:
            XCTAssertTrue(false)
        }
    }
    
}
