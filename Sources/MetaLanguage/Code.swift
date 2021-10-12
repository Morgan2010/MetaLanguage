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
        let sanitisedCode = code.trimmingCharacters(in: .newlines).removeRedundentIndentation
        self = .languageCode(code: sanitisedCode, language: language)
    }
    
    public init?(rawValue: String) {
        //Used for meta language
        return nil
    }
    
}

extension Code: Codable, Equatable, Hashable {}
