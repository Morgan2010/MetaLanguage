//
//  File.swift
//  File
//
//  Created by Morgan McColl on 9/10/21.
//

import Foundation
import SwiftParsing

/// An enum to represent Test Cases in different languages
public enum Test {
    
    case languageTest(name: String, code: String, language: Language)
    
    /// Parses a raw string into a generic Test enum
    public init?(rawValue: String) {
        guard
            let metaData = rawValue.findSubString(with: "@", and: "{"),
            let codeFirstIndex = metaData.lastIndex,
            let code = String(rawValue[codeFirstIndex..<rawValue.countIndex]).findSubString(between: "{", and: "}")
        else {
            return nil
        }
        let components = metaData.value.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: .whitespacesAndNewlines)
        if components.count == 3 {
            if components[1] != "test" {
                return nil
            }
            if let language = Language(rawValue: components[0]) {
                let name = components[2]
                let sanitisedCode = String(code.value).trimmingCharacters(in: .newlines).removeRedundentIndentation
                self = .languageTest(name: name, code: sanitisedCode, language: language)
                return
            }
        }
        return nil
    }
    
}

extension Test: Codable, Equatable, Hashable {}
