//
//  File.swift
//  File
//
//  Created by Morgan McColl on 9/10/21.
//

import Foundation
import XCTest
@testable import LLFSMTestingFramework

final class TestTests: XCTestCase {
    
    var testData: String?
    
    override func setUp() {
        testData = "    @swift test trueTest {\n        XCTAssertTrue(true)\n    }"
    }
    
    func testCreatesValidTest() {
        let test = Test(rawValue: testData!)
        let expected: Test = .languageTest(name: "testTrueTest", code: "XCTAssertTrue(true)", language: .swift)
        XCTAssertNotNil(test)
        compareTest(uut: test, expected: expected)
    }
    
    private func compareTest(uut: Test?, expected: Test) {
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
