//
//  File.swift
//  File
//
//  Created by Morgan McColl on 9/10/21.
//

import Foundation
import SwiftParsing

public struct TestSuite {
    
    public var name: String
    
    public var variables: [Variable]?
    
    public var setup: Code?
    
    public var tearDown: Code?
    
    public var tests: [Test]
    
    public init(name: String, tests: [Test], variables: [Variable]? = nil, setup: Code? = nil, tearDown: Code? = nil) {
        self.name = name
        self.tests = tests
        self.setup = setup
        self.variables = variables
        self.tearDown = tearDown
    }
    
    public init?(rawValue: String) {
        let selector = StringSelector()
        guard let subString = selector.findIndexes(for: "TestSuite", in: rawValue) else {
            return nil
        }
        let firstCandidate = subString.endIndex
        let nameCandidates = IndexableSubString(parent: rawValue, indexes: firstCandidate..<rawValue.countIndex)
        guard let lastIndex = nameCandidates.firstIndex(where: { $0 == "{" }) else {
            return nil
        }
        let desirables = String(rawValue[lastIndex..<rawValue.countIndex])
        let components = rawValue[firstCandidate..<lastIndex].trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: .whitespacesAndNewlines)
        guard
            components.count == 1,
            let testsRaw = selector.findSubString(between: "{", and: "}", in: desirables),
            let desirableOffset = testsRaw.lastIndex?.utf16Offset(in: desirables)
        else {
            return nil
        }
        let testsLastIndex = String.Index(utf16Offset: desirableOffset + lastIndex.utf16Offset(in: rawValue), in: rawValue)
        self.name = components[0]
        var currentIndex = lastIndex
        var testsGrouped: [IndexableSubString] = []
        var setup: Code? = nil
        var tearDown: Code? = nil
        var variables: [Variable] = []
        let mutator = StringMutator()
        while currentIndex < testsLastIndex {
            let groupMetaData = selector.findSubString(after: currentIndex, with: ["@"], and: ["{", "@", "}"], in: rawValue)
            guard
                let metaData = groupMetaData?.value.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: .whitespacesAndNewlines),
                let codeFirstIndex = groupMetaData?.lastIndex,
                let code = selector.findSubString(after: codeFirstIndex, with: "{", and: "}", in: rawValue),
                let searchedLastIndex = code.lastIndex,
                let codeLastIndex = code.endIndex.increment(in: rawValue),
                let groupMetaData = groupMetaData,
                let testFirstIndex = groupMetaData.startIndex.decrement(in: rawValue),
                let groupLastIndex = groupMetaData.lastIndex,
                metaData.count > 0
            else {
                currentIndex = testsLastIndex
                continue
            }
            if (metaData.count > 2 && metaData[1] == "variable") || metaData[0] == "variable" {
                guard let nextKeyword = selector.findSubString(after: codeFirstIndex, with: ["@"], and: ["{", "@"], in: rawValue) else {
                    if let variable = Variable(rawValue: String(groupMetaData.value)) {
                        variables.append(variable)
                    }
                    currentIndex = groupLastIndex
                    continue
                }
                if nextKeyword.indexes.lowerBound < code.indexes.lowerBound {
                    if let variable = Variable(rawValue: String(groupMetaData.value)) {
                        variables.append(variable)
                    }
                    currentIndex = groupLastIndex
                    continue
                }
                if let variable = Variable(rawValue: String(groupMetaData.value)
                   + mutator.createBlock(for: mutator.removeRedundentIndentation(data: String(code.value).trimmingCharacters(in: .newlines))))
                {
                    variables.append(variable)
                }
                currentIndex = code.endIndex
                continue
            }
            if (metaData.count == 3 && metaData[1] == "test") || metaData[0] == "test" {
                let newTest = IndexableSubString(parent: rawValue, indexes: testFirstIndex..<codeLastIndex)
                testsGrouped.append(newTest)
                currentIndex = code.endIndex
                continue
            }
            if metaData.count == 2 && metaData[1] == "setup" {
                currentIndex = code.endIndex
                if setup != nil {
                    continue
                }
                guard let language = Language(rawValue: metaData[0].trimmingCharacters(in: .whitespacesAndNewlines)) else {
                    continue
                }
                setup = Code(code: String(code.value), language: language)
                continue
            }
            if metaData.count == 2 && metaData[1] == "teardown" {
                currentIndex = code.endIndex
                if tearDown != nil {
                    continue
                }
                guard let language = Language(rawValue: metaData[0].trimmingCharacters(in: .whitespacesAndNewlines)) else {
                    continue
                }
                tearDown = Code(code: String(code.value), language: language)
                continue
            }
            if metaData[0] == "setup" {
                currentIndex = code.endIndex
                if setup != nil {
                    continue
                }
                setup = Code(rawValue: String(code.value))
                continue
            }
            if metaData[0] == "teardown" {
                currentIndex = code.endIndex
                if tearDown != nil {
                    continue
                }
                tearDown = Code(rawValue: String(code.value))
                continue
            }
            currentIndex = searchedLastIndex
        }
        self.tests = testsGrouped.compactMap { Test(rawValue: String($0.value)) }
        self.setup = setup
        self.tearDown = tearDown
        self.variables = variables.isEmpty ? nil : variables
    }
    
}

extension TestSuite: Codable, Equatable, Hashable {}
