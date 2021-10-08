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
        rawData = "TestSuite ExampleTests {\n    @swift test trueTest {\n        XCTAssertTrue(true)\n    }\n\n    @swift test falseTest {\n        XCTAssertTrue(false)\n    }\n}"
    }
    
    func testIsValid() {
        let expected = TestSuite(
            name: "ExampleTests",
            tests: [
                .languageTest(name: "testTrueTest", code: "XCTAssertTrue(true)", language: .swift),
                .languageTest(name: "testFalseTest", code: "XCTAssertTrue(false)", language: .swift)
            ]
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
    }
    
}

