//
//  File.swift
//  File
//
//  Created by Morgan McColl on 11/10/21.
//

import Foundation
import XCTest
import LLFSMTestingFramework
@testable import SwiftTests

final class SwiftGeneratorTests: XCTestCase {
    
    var suite: TestSuite?
    
    var generator: SwiftGenerator?
    
    var expected: String?
    
    private let packageRootPath = URL(fileURLWithPath: #file).pathComponents.prefix(while: { $0 != "Tests" }).joined(separator: "/").dropFirst()
    
    override func setUp() {
        suite = TestSuite(
            name: "ExampleSuite",
            tests: [
                .languageTest(name: "testCheckX", code: "XCTAssertEqual(x, 5)", language: .swift),
                .languageTest(name: "testCheckY", code: "XCTAssertEqual(y, 6)", language: .swift),
                .languageTest(name: "testArray", code: "let arr = [0, 1, 2]\narr.enumerated().forEach{\n    XCTAssertEqual($0.0, $0.1)\n}", language: .swift)
            ],
            variables: [
                .languageVariable(name: "x", declaration: "var x: Int?", language: .swift),
                .languageVariable(name: "y", declaration: "var y: Int?", language: .swift)
            ],
            setup: .languageCode(code: "x = 5\ny = 6", language: .swift)
        )
        generator = SwiftGenerator()
    }
    
    func testCodeGeneration() {
        let result = generator?.generate(suite: suite!)
        XCTAssertNotNil(result)
        print(result!)
    }
    
    func testExampleTest() {
        guard
            let data = try? String(contentsOf: URL(fileURLWithPath: packageRootPath + "/Tests/SwiftTestsTests/examples/ExampleTest")),
            let suite = TestSuite(rawValue: data),
            let wrapper = generator?.generateWrapper(suite: suite),
            let _ = try? wrapper.write(to: URL(fileURLWithPath: packageRootPath + "/Tests/SwiftTestsTests/examples/ExampleTest.swift"), options: .atomic, originalContentsURL: nil)
        else {
            XCTAssertTrue(false)
            return
        }
        XCTAssertTrue(true)
    }
    
}
