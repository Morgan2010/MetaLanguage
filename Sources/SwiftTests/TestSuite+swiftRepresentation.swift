//
//  File.swift
//  File
//
//  Created by Morgan McColl on 12/10/21.
//

import Foundation
import MetaLanguage
import SwiftParsing

extension TestSuite {
    
    var swiftRepresentation: String? {
        let mutator = StringMutator()
        let variables = variables?.compactMap(\.swiftRepresentation) ?? []
        let setup = nil == setup ? "" : (setup!.swiftSetupRepresentation ?? "")
        let teardown = nil == tearDown ? "" : (tearDown!.swiftTearDownRepresentation ?? "")
        let tests = tests.compactMap(\.swiftRepresentation)
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
        return header + "\n\n" + "final class \(name): XCTestCase " + mutator.createBlock(for: blockCode)
    }
    
}
