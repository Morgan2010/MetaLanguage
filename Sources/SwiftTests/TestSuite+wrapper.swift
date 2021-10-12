//
//  File.swift
//  File
//
//  Created by Morgan McColl on 11/10/21.
//

import Foundation
import MetaLanguage
import SwiftParsing

public extension TestSuite {
    
    /// Converts a TestSuite into a FileWrapper with swift code in it's contents
    var wrapper: FileWrapper? {
        guard
            let tests = self.swiftRepresentation,
            let data = tests.data(using: .utf8)
        else {
            return nil
        }
        let wrapper = FileWrapper(regularFileWithContents: data)
        wrapper.preferredFilename = "\(self.name).swift"
        return wrapper
    }
    
}
