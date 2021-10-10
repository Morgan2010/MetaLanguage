//
//  File.swift
//  File
//
//  Created by Morgan McColl on 11/10/21.
//

import Foundation
import XCTest
@testable import LLFSMTestingFramework

final class VariableTests: XCTestCase {
    
    var data: String?
    
    override func setUp() {
        data = "swift variable var x: Int?"
    }
    
    func testInit() {
        let result = Variable(rawValue: data!)
        compareVariables(uut: result, expected: .languageVariable(declaration: "var x: Int?", language: .swift))
        
    }
    
    func testNestedVariable() {
        let raw = "    swift variable var x: Int {\n        return 5\n    }"
        let result = Variable(rawValue: raw)
        let expected: Variable = .languageVariable(declaration: "var x: Int {\n    return 5\n}", language: .swift)
        compareVariables(uut: result, expected: expected)
    }
    
    private func compareVariables(uut: Variable?, expected: Variable) {
        XCTAssertNotNil(uut)
        switch uut! {
        case .languageVariable(let declaration, let language):
            switch expected {
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

