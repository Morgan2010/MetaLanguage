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
                guard let firstChar = name.first else {
                    return nil
                }
                if !name.starts(with: "test") {
                    name = "test" + firstChar.uppercased() + name.dropFirst()
                }
                self = .languageTest(name: name, code: String(code.value), language: language)
                return
            }
        }
        return nil
    }
    
}
