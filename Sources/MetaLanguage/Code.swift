//
//  File.swift
//  File
//
//  Created by Morgan McColl on 9/10/21.
//

import Foundation
import SwiftParsing

/// An enum representing arbitrary code without context.
public enum Code {
    
    case languageCode(code: String, language: Language)
    
    /// Create a Code from previous parsed data.
    /// - Parameters:
    ///   - code: The code written in the language specified
    ///   - language: The language the code is written in
    public init(code: String, language: Language) {
        let sanitisedCode = code.trimmingCharacters(in: .newlines).removeRedundentIndentation
        self = .languageCode(code: sanitisedCode, language: language)
    }
    
    /// A raw string representing an abstract code. This initialiser will parse and if successful categorise the code in a language.
    public init?(rawValue: String) {
        //Used for meta language
        return nil
    }
    
}

extension Code: Codable, Equatable, Hashable {}
