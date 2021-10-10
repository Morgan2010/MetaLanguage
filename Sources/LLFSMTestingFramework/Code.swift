//
//  File.swift
//  File
//
//  Created by Morgan McColl on 9/10/21.
//

import Foundation
import SwiftParsing

public enum Code {
    
    case languageCode(code: String, language: Language)
    
    public init(code: String, language: Language) {
        let mutator = StringMutator()
        let sanitisedCode = mutator.removeRedundentIndentation(data: code.trimmingCharacters(in: .newlines))
        self = .languageCode(code: sanitisedCode, language: language)
    }
    
}
