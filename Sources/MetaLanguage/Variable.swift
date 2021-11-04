//
//  File.swift
//  File
//
//  Created by Morgan McColl on 9/10/21.
//

import Foundation
import SwiftParsing

/// An enum representing an abstract variable in any language
public enum Variable: CustomStringConvertible {
    
    case languageVariable(declaration: String, language: Language)
    
    /// Tries to parse a raw string to determine a variable and it's language
    public init?(rawValue: String) {
        let metaData = rawValue.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: .whitespacesAndNewlines)
        guard metaData.count >= 2 else {
            return nil
        }
        if metaData[1] == "variable" {
            guard
                let language = Language(rawValue: metaData[0].starts(with: "@") ? String(metaData[0].dropFirst()) : metaData[0]),
                let variableSubString = rawValue.findIndexes(for: "variable"),
                let startSubString = rawValue.findIndexes(for: metaData[0]),
                let firstIndex = rawValue.firstIndex
            else {
                return nil
            }
            let declarationFirstIndex = variableSubString.endIndex
            let indentation = rawValue[firstIndex..<startSubString.indexes.lowerBound]
            let code = rawValue[declarationFirstIndex..<rawValue.countIndex].trimmingCharacters(in: .whitespacesAndNewlines)
            let newData: String = String(indentation + code)
            let sanitisedDeclaration = newData.trimmingCharacters(in: .newlines).removeRedundentIndentation
            self = .languageVariable(declaration: sanitisedDeclaration, language: language)
            return
        }
        return nil
    }

    /// A meta language representation of this variable
    public var description: String {
        switch self {
        case .languageVariable(let declaration, let language):
            return "@\(language.description) variable \(declaration)"
        }
    }
    
}

extension Variable: Equatable, Hashable {}

extension Variable: Codable {

    enum CodingKeys: CodingKey {
        case languageVariable
    }

    struct VariableContainer: Codable {

        let declaration: String

        let language: Language

    }

    /// Initialise the Variable from a Decoder
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        guard let key = container.allKeys.first else {
            fatalError("Failed to retrieve key.")
        }
        switch key {
        case .languageVariable:
            let variableContainer = try container.decode(VariableContainer.self, forKey: .languageVariable)
            self = .languageVariable(declaration: variableContainer.declaration, language: variableContainer.language)
        }
    }

    /// Encode the variable into an Encoder object.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .languageVariable(let declaration, let language):
            try container.encode(VariableContainer(declaration: declaration, language: language), forKey: .languageVariable)
        }
    }

}

