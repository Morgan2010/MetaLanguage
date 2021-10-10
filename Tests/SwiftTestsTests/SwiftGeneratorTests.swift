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
    
    override func setUp() {
        suite = TestSuite(
            name: "ExampleSuite",
            tests: [
                .languageTest(name: "testCheckX", code: "XCTAssertEqual(x, 5)", language: .swift),
                .languageTest(name: "testCheckY", code: "XCTAssertEqual(y, 6)", language: .swift)
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
    
}
