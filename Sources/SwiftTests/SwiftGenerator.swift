//
//  File.swift
//  File
//
//  Created by Morgan McColl on 11/10/21.
//

import Foundation
import LLFSMTestingFramework

struct SwiftGenerator {
    
    public func generateWrapper(suite: TestSuite, fileName: String) -> FileWrapper? {
        guard
            let tests = generate(suite: suite),
            let data = tests.data(using: .utf8)
        else {
            return nil
        }
        let wrapper = FileWrapper(regularFileWithContents: data)
        wrapper.preferredFilename = fileName
        return wrapper
    }
    
    public func generate(suite: TestSuite) -> String? {
        return nil
    }
    
}
