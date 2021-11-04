//
//  File.swift
//  File
//
//  Created by Morgan McColl on 9/10/21.
//

import Foundation
#if os(Linux) && canImport(Foundation) && !NO_FOUNDATION
import IO
#endif
import XCTest
@testable import MetaLanguage 

final class TestSuiteTests: XCTestCase {
    
    var rawData: String!
    var expected: TestSuite!
    
    override func setUp() {
        expected = TestSuite(
            name: "ExampleTests",
            tests: [
                .languageTest(name: "test_trueTest", code: "XCTAssertTrue(true)", language: .swift),
                .languageTest(name: "test_falseTest", code: "XCTAssertTrue(false)", language: .swift)
            ],
            variables: [.languageVariable(declaration: "var x: Int?", language: .swift)],
            setup: .languageCode(code: "print(\"Hello World!\")", language: .swift),
            tearDown: .languageCode(code: "print(\"Tear Down!\")", language: .swift)
        )
        rawData = "TestSuite ExampleTests {\n    @swift variable var x: Int?\n\n    @swift setup {\n        print(\"Hello World!\")"
            + "\n    }\n\n    @swift teardown {\n        print(\"Tear Down!\")\n    }\n\n    "
            + "@swift test test_trueTest {\n        XCTAssertTrue(true)\n    }\n\n"
            + "    @swift test test_falseTest {\n        XCTAssertTrue(false)\n    }\n}"
    }
    
    func testIsValid() {
        let suite = TestSuite(rawValue: rawData)
        XCTAssertNotNil(suite)
        compareTestSuite(uut: suite, expected: expected)
    }
    
    func testJSONEncoding() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard
            let data = try? encoder.encode(expected),
            let jsonString = String(data: data, encoding: .utf8)
        else {
            XCTAssertTrue(false)
            return
        }
        print(jsonString)
        let decoder = JSONDecoder()
        guard
            let jsonData = jsonString.data(using: .utf8),
            let newSuite = try? decoder.decode(TestSuite.self, from: jsonData)
        else {
            XCTAssertTrue(false)
            return
        }
        XCTAssertEqual(expected, newSuite)
    }

    func testDescription() {
        testLines(str1: expected.description, str2: rawData.description)
    }

    func testWrapperInit() {
        let code = expected.description
        guard let data = code.data(using: .utf16) else {
            XCTAssertTrue(false)
            return
        }
        let wrapper = FileWrapper(regularFileWithContents: data)
        let newSuite = TestSuite(wrapper: wrapper)
        XCTAssertNotNil(newSuite)
        XCTAssertEqual(expected, newSuite)
    }

    private func testLines(str1: String, str2: String) {
        let str1Lines = str1.components(separatedBy: .newlines).map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        let str2Lines = str2.components(separatedBy: .newlines).map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        XCTAssertEqual(str1Lines.count, str2Lines.count)
        for i in str1Lines.indices {
            XCTAssertEqual(str1Lines[i], str2Lines[i])
        }
    }
    
    private func compareTestSuite(uut: TestSuite?, expected: TestSuite) {
        guard uut != nil else {
            XCTAssertNotNil(uut)
            return
        }
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

