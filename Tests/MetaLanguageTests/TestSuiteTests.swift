//
//  File.swift
//  File
//
//  Created by Morgan McColl on 9/10/21.
//

import Foundation
import XCTest
@testable import MetaLanguage 

final class TestSuiteTests: XCTestCase {
    
    var rawData: String?
    
    override func setUp() {
        rawData = "TestSuite ExampleTests {\n    @swift variable var x: Int?\n\n    @swift setup {\n    print(\"Hello World!\")"
            + "\n}\n\n    @swift teardown {\n        print(\"Tear Down!\")\n    }\n\n    "
            + "@swift test trueTest {\n        XCTAssertTrue(true)\n    }\n\n"
            + "    @swift test falseTest {\n        XCTAssertTrue(false)\n    }\n}"
    }
    
    func testIsValid() {
        let expected = TestSuite(
            name: "ExampleTests",
            tests: [
                .languageTest(name: "test_trueTest", code: "XCTAssertTrue(true)", language: .swift),
                .languageTest(name: "test_falseTest", code: "XCTAssertTrue(false)", language: .swift)
            ],
            variables: [.languageVariable(declaration: "var x: Int?", language: .swift)],
            setup: .languageCode(code: "print(\"Hello World!\")", language: .swift),
            tearDown: .languageCode(code: "print(\"Tear Down!\")", language: .swift)
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
        if expected.setup != nil {
            compareCode(uut: uut?.setup, expected: expected.setup!)
        }
        if expected.tearDown != nil {
            compareCode(uut: uut?.tearDown, expected: expected.tearDown!)
        }
        XCTAssertEqual(uut?.variables?.indices, expected.variables?.indices)
        if expected.variables != nil {
            XCTAssertNotNil(uut?.variables)
            let vars = uut!.variables!
            let expectedVars = expected.variables!
            vars.indices.forEach {
                switch vars[$0] {
                case .languageVariable(let declaration, let language):
                    switch expectedVars[$0] {
                    case .languageVariable(let declaration2, let language2):
                        XCTAssertEqual(declaration, declaration2)
                        XCTAssertEqual(language, language2)
                    default:
                        XCTAssertTrue(false)
                    }
                default:
                    XCTAssertTrue(false)
                }
            }
        }
        
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

