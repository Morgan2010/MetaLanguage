//
//  File.swift
//  File
//
//  Created by Morgan McColl on 9/10/21.
//

import Foundation
import XCTest
@testable import LLFSMTestingFramework

final class TestSuiteTests: XCTestCase {
    
    var rawData: String?
    
    override func setUp() {
        rawData = "TestSuite ExampleTests {\n    @swift setup {\n    print(\"Hello World!\")\n}\n\n    @swift test trueTest {\n        XCTAssertTrue(true)\n    }\n\n    @swift test falseTest {\n        XCTAssertTrue(false)\n    }\n}"
    }
    
    func testIsValid() {
        let expected = TestSuite(
            name: "ExampleTests",
            tests: [
                .languageTest(name: "testTrueTest", code: "XCTAssertTrue(true)", language: .swift),
                .languageTest(name: "testFalseTest", code: "XCTAssertTrue(false)", language: .swift)
            ],
            setup: .languageCode(code: "print(\"Hello World!\")", language: .swift)
        )
        let suite = TestSuite(rawValue: rawData!)
        XCTAssertNotNil(suite)
        compareTestSuite(uut: suite, expected: expected)
    }
    
    private func compareTestSuite(uut: TestSuite?, expected: TestSuite) {
        XCTAssertEqual(uut?.name, expected.name)
        XCTAssertEqual(uut?.tests.count, expected.tests.count)
        uut?.tests.indices.forEach {
            TestTests.compareTest(uut: uut?.tests[$0], expected: expected.tests[$0])
        }
        compareCode(uut: uut?.setup, expected: expected.setup!)
    }
    
    private func compareCode(uut: Code?, expected: Code) {
        XCTAssertNotNil(uut)
        switch uut! {
        case .languageCode(let code, let language):
            switch expected {
            case .languageCode(let code2, let language2):
                XCTAssertEqual(
                    code.trimmingCharacters(in: .whitespacesAndNewlines)
                        .components(separatedBy: .newlines)
                        .map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) })
                        .joined(separator: "\n"),
                    code2
                )
                XCTAssertEqual(language, language2)
            }
        default:
            XCTAssertTrue(false)
        }
    }
    
}

