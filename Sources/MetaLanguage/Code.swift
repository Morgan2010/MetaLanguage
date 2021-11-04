//
//  File.swift
//  File
//
//  Created by Morgan McColl on 9/10/21.
//

import Foundation
import SwiftParsing

/// An enum representing arbitrary code without context.
public enum Code: CustomStringConvertible {
    
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

    /// The meta language representation of this Code.
    public var description: String {
        switch self {
        case .languageCode(let code, let language):
            return code
        }
    }
    
}

extension Code: Equatable, Hashable {}

extension Code: Codable {

    enum CodingKeys: CodingKey {
        case languageCode
    }

    struct CodeContainer: Codable {

        let code: String

        let language: Language

    }

    /// Initialise the Code from a Decoder
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        guard let key = container.allKeys.first else {
            fatalError("Failed to retrieve key")
        }
        switch key {
        case .languageCode:
            let codeContainer = try container.decode(CodeContainer.self, forKey: .languageCode)
            self = .languageCode(code: codeContainer.code, language: codeContainer.language)
        default:
            fatalError("Data corruption")
        }
    }

    /// Encode the contents of this code inside an Encoder
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .languageCode(let code, let language):
            try container.encode(CodeContainer(code: code, language: language), forKey: .languageCode)
        }
    }

}

