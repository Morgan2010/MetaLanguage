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
    
    public var tests: [Test]
    
    public init(name: String, tests: [Test], variables: [Variable]? = nil, setup: Code? = nil) {
        self.name = name
        self.tests = tests
        self.setup = setup
        self.variables = variables
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
        while currentIndex < testsLastIndex {
            let groupMetaData = selector.findSubString(after: currentIndex, with: "@", and: "{", in: rawValue)
            guard
                let metaData = groupMetaData?.value.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: .whitespacesAndNewlines),
                let codeFirstIndex = groupMetaData?.lastIndex,
                let code = selector.findSubString(after: codeFirstIndex, with: "{", and: "}", in: rawValue),
                let searchedLastIndex = code.lastIndex,
                let codeLastIndex = code.endIndex.increment(in: rawValue),
                let testFirstIndex = groupMetaData?.startIndex.decrement(in: rawValue)
            else {
                currentIndex = testsLastIndex
                continue
            }
            if metaData.count == 3 {
                if metaData[1] == "test" {
                    let newTest = IndexableSubString(parent: rawValue, indexes: testFirstIndex..<codeLastIndex)
                    testsGrouped.append(newTest)
                }
                currentIndex = code.endIndex
                continue
            }
            if metaData.count == 2 {
                if metaData[1] == "setup" {
                    currentIndex = code.endIndex
                    if setup != nil {
                        continue
                    }
                    guard let language = Language(rawValue: metaData[0].trimmingCharacters(in: .whitespacesAndNewlines)) else {
                        continue
                    }
                    setup = Code(code: String(code.value), language: language)
                }
            }
            currentIndex = searchedLastIndex
        }
        self.tests = testsGrouped.compactMap { Test(rawValue: String($0.value)) }
        self.setup = setup
    }
    
}
