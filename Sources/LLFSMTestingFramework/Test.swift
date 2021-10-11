//
//  File.swift
//  File
//
//  Created by Morgan McColl on 9/10/21.
//

import Foundation
import SwiftParsing

public enum Test {
    
    case languageTest(name: String, code: String, language: Language)
    
    public init?(rawValue: String) {
        let selector = StringSelector()
        guard
            let metaData = selector.findSubString(with: "@", and: "{", in: rawValue),
            let codeFirstIndex = metaData.lastIndex,
            let code = selector.findSubString(between: "{", and: "}", in: String(rawValue[codeFirstIndex..<rawValue.countIndex]))
        else {
            return nil
        }
        let components = metaData.value.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: .whitespacesAndNewlines)
        if components.count == 3 {
            if components[1] != "test" {
                return nil
            }
            if let language = Language(rawValue: components[0]) {
                var name = components[2]
                if !name.starts(with: "test_") {
                    name = "test_" + name
                }
                let mutator = StringMutator()
                let sanitisedCode = mutator.removeRedundentIndentation(data: String(code.value).trimmingCharacters(in: .newlines))
                self = .languageTest(name: name, code: sanitisedCode, language: language)
                return
            }
        }
        return nil
    }
    
}
