//
//  File.swift
//  File
//
//  Created by Morgan McColl on 11/10/21.
//

import Foundation
import MetaLanguage
import SwiftParsing

public struct SwiftGenerator {
    
    let mutator: StringMutator
    
    public init(mutator: StringMutator = StringMutator()) {
        self.mutator = mutator
    }
    
    public func generateWrapper(suite: TestSuite) -> FileWrapper? {
        guard
            let tests = generate(suite: suite),
            let data = tests.data(using: .utf8)
        else {
            return nil
        }
        let wrapper = FileWrapper(regularFileWithContents: data)
        wrapper.preferredFilename = "\(suite.name).swift"
        return wrapper
    }
    
    public func generate(suite: TestSuite) -> String? {
        let variables = suite.variables?.compactMap(toString) ?? []
        let setup = nil == suite.setup ? "" : (toString(setup: suite.setup!) ?? "")
        let teardown = nil == suite.tearDown ? "" : (toString(teardown: suite.tearDown!) ?? "")
        let tests = suite.tests.compactMap(toString)
        guard tests.count > 0 else {
            return nil
        }
        let variableCode = variables.reduce("") { mutator.joinWithNewLines(str1: $0, str2: $1, amount: 2) }
        let testsCode = tests.reduce("") { mutator.joinWithNewLines(str1: $0, str2: $1, amount: 2) }
        let header = "import Foundation\nimport XCTest"
        let blockCode = "\n" + mutator.joinWithNewLines(
            str1: mutator.joinWithNewLines(
                str1: mutator.joinWithNewLines(str1: variableCode, str2: setup, amount: 2),
                str2: teardown,
                amount: 2
            ),
            str2: testsCode, amount: 2
        ) + "\n"
        return header + "\n\n" + "final class \(suite.name): XCTestCase " + mutator.createBlock(for: blockCode)
    }
    
    private func toString(test: Test) -> String? {
        switch test {
        case .languageTest(let name, let code, let language):
            switch language {
            case .swift:
                return "func \(name)() " + mutator.createBlock(for: code)
            default:
                return nil
            }
        default:
            return nil
        }
    }
    
    private func toString(setup: Code) -> String? {
        switch setup {
        case .languageCode(let code, let language):
            switch language {
            case .swift:
                return "override func setUp() " + mutator.createBlock(for: code)
            default:
                return nil
            }
        default:
            return nil
        }
    }
    
    private func toString(teardown: Code) -> String? {
        switch teardown {
        case .languageCode(let code, let language):
            switch language {
            case .swift:
                return "override func tearDown() " + mutator.createBlock(for: code)
            default:
                return nil
            }
        default:
            return nil
        }
    }
    
    private func toString(variable: Variable) -> String? {
        switch variable {
        case .languageVariable(let declaration, let language):
            switch language {
            case .swift:
                return declaration
            default:
                return nil
            }
        }
    }
    
}
