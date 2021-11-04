//
//  File.swift
//  File
//
//  Created by Morgan McColl on 11/10/21.
//

import Foundation
#if os(Linux) && canImport(Foundation) && !NO_FOUNDATION
import IO
#endif
import XCTest
@testable import MetaLanguage
@testable import SwiftTests

final class WrapperTests: XCTestCase {
    
    var suite: TestSuite!
    
    var expected: String!
    
    private let packageRootPath = URL(fileURLWithPath: #file).pathComponents.prefix(while: { $0 != "Tests" }).joined(separator: "/").dropFirst()
    
    override func setUp() {
        suite = TestSuite(
            name: "ExampleSuite",
            tests: [
                .languageTest(name: "checkX", code: "XCTAssertEqual(x, 5)", language: .swift),
                .languageTest(name: "checkY", code: "XCTAssertEqual(y, 6)", language: .swift),
                .languageTest(name: "array", code: "let arr = [0, 1, 2]\narr.enumerated().forEach{\n    XCTAssertEqual($0.0, $0.1)\n}", language: .swift)
            ],
            variables: [
                .languageVariable(declaration: "var x: Int?", language: .swift),
                .languageVariable(declaration: "var y: Int?", language: .swift)
            ],
            setup: .languageCode(code: "x = 5\ny = 6", language: .swift),
            tearDown: .languageCode(code: "print(\"Tear Down!\")", language: .swift)
        )
    }
    
    func testCodeGeneration() {
        let result = suite.swiftRepresentation
        XCTAssertNotNil(result)
        print(result!)
    }
    
    func testExampleTest() {
        guard
            let data = try? String(contentsOf: URL(fileURLWithPath: packageRootPath + "/Tests/SwiftTestsTests/examples/ExampleTest")),
            let suite = TestSuite(rawValue: data),
            let wrapper = suite.wrapper,
            let _ = try? wrapper.write(to: URL(fileURLWithPath: packageRootPath + "/Tests/SwiftTestsTests/examples/ExampleTest.swift"), options: .atomic, originalContentsURL: nil)
        else {
            XCTAssertTrue(false)
            return
        }
        XCTAssertTrue(true)
    }
    
    func testJSONFile() {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        guard let suiteData = try? encoder.encode(suite) else {
            XCTAssertTrue(false)
            return
        }
        let wrapper = FileWrapper(regularFileWithContents: suiteData)
        let url = URL( fileURLWithPath: packageRootPath + "/Tests/SwiftTestsTests/examples/ExampleTest.json"
        )
        guard
            let _ = try? wrapper.write(
                to: url,
                options: .atomic,
                originalContentsURL: nil
            ),
            let contents = try? Data(contentsOf: url),
            let newSuite = try? decoder.decode(TestSuite.self, from: contents)
        else {
            XCTAssertTrue(false)
            return
        }
        XCTAssertEqual(suite, newSuite)
    }
    
}
