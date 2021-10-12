//
//  File.swift
//  File
//
//  Created by Morgan McColl on 9/10/21.
//

import Foundation
import SwiftParsing

/// An enum representing an abstract variable in any language
public enum Variable {
    
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
    
}

extension Variable: Codable, Equatable, Hashable {}
