//
//  File.swift
//  File
//
//  Created by Morgan McColl on 9/10/21.
//

import Foundation
import SwiftParsing

/// An enum to represent Test Cases in different languages
public enum Test: CustomStringConvertible {
    
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
                var name = components[2]
                if !name.starts(with: "test") {
                    name = "test_" + name
                }
                let sanitisedCode = String(code.value).trimmingCharacters(in: .newlines).removeRedundentIndentation
                self = .languageTest(name: name, code: sanitisedCode, language: language)
                return
            }
        }
        return nil
    }

    public var description: String {
        switch self {
        case .languageTest(let name, let code, let language):
            return "@\(language.description) test \(name) " + code.createBlock
        }
    }
    
}

extension Test: Equatable, Hashable {}

extension Test: Codable {
    
    enum CodingKeys: CodingKey {
        case languageTest
    }

    struct LanguageTestContainer: Codable {

        let name: String

        let code: String

        let language: Language

    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        guard let key = container.allKeys.first else {
            fatalError("Failed to retrieve key")
        }
        switch key {
        case .languageTest:
            let testContainer = try container.decode(LanguageTestContainer.self, forKey: .languageTest)
            self = .languageTest(
                name: testContainer.name,
                code: testContainer.code,
                language: testContainer.language
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .languageTest(let name, let code, let language):
            try container.encode(
                LanguageTestContainer(name: name, code: code, language: language),
                forKey: .languageTest
            )
        }
    }

}

