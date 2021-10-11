//
//  File.swift
//  File
//
//  Created by Morgan McColl on 9/10/21.
//

import Foundation
import SwiftParsing

public enum Variable {
    
    case languageVariable(declaration: String, language: Language)
    
    public init?(rawValue: String) {
        let metaData = rawValue.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: .whitespacesAndNewlines)
        if metaData[1] == "variable" {
            let selector = StringSelector()
            guard
                let language = Language(rawValue: metaData[0].starts(with: "@") ? String(metaData[0].dropFirst()) : metaData[0]),
                let variableSubString = selector.findIndexes(for: "variable", in: rawValue),
                let startSubString = selector.findIndexes(for: metaData[0], in: rawValue),
                let firstIndex = rawValue.firstIndex
            else {
                return nil
            }
            let declarationFirstIndex = variableSubString.endIndex
            let mutator = StringMutator()
            let indentation = rawValue[firstIndex..<startSubString.indexes.lowerBound]
            let code = rawValue[declarationFirstIndex..<rawValue.countIndex].trimmingCharacters(in: .whitespacesAndNewlines)
            let newData = String(indentation + code)
            let sanitisedDeclaration = mutator.removeRedundentIndentation(data: newData.trimmingCharacters(in: .newlines))
            self = .languageVariable(declaration: sanitisedDeclaration, language: language)
            return
        }
        return nil
    }
    
}

extension Variable: Codable {}
