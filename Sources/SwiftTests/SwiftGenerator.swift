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
    
    public init() {}
    
    public func generateWrapper(suite: TestSuite) -> FileWrapper? {
        guard
            let tests = suite.swiftRepresentation,
            let data = tests.data(using: .utf8)
        else {
            return nil
        }
        let wrapper = FileWrapper(regularFileWithContents: data)
        wrapper.preferredFilename = "\(suite.name).swift"
        return wrapper
    }
    
}
