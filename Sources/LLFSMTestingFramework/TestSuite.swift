//
//  File.swift
//  File
//
//  Created by Morgan McColl on 9/10/21.
//

import Foundation
import SwiftParsing

struct TestSuite {
    
    var name: String
    
    var variables: [Variable]?
    
    var setup: Code?
    
    var tests: [Test]
    
    init?(rawValue: String) {
        let selector = StringSelector()
        guard let subString = selector.findIndexes(for: "TestSuite", in: rawValue) else {
            return nil
        }
        let firstCandidate = subString.endIndex
        let nameCandidates = IndexableSubString(parent: rawValue, indexes: firstCandidate..<rawValue.countIndex)
        guard let lastIndex = nameCandidates.firstIndex(where: { $0 == "{" }) else {
            return nil
        }
        let components = rawValue[firstCandidate..<lastIndex].trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: .whitespacesAndNewlines)
        guard
            components.count == 1,
            let testCandidateIndex = lastIndex.decrement(in: rawValue),
            let testsRaw = selector.findSubString(after: testCandidateIndex, with: "{", and: "}", in: String(rawValue[lastIndex..<rawValue.countIndex])),
            let testsLastIndex = testsRaw.lastIndex
        else {
            return nil
        }
        self.name = components[0]
        var currentIndex = testCandidateIndex
        var testsGrouped: [IndexableSubString] = []
        repeat {
            guard let groupMetaData = selector.findSubString(after: currentIndex, with: "@", and: "{", in: rawValue) else {
                currentIndex = testsRaw.endIndex
                continue
            }
            let metaData = groupMetaData.value.components(separatedBy: .whitespacesAndNewlines)
            guard
                let codeFirstIndex = groupMetaData.endIndex.decrement(in: rawValue),
                let code = selector.findSubString(after: codeFirstIndex, with: "{", and: "}", in: rawValue)
            else {
                currentIndex = testsRaw.endIndex
                continue
            }
            guard let searchedLastIndex = code.lastIndex else {
                currentIndex = testsRaw.endIndex
                continue
            }
            guard metaData.count == 3 else {
                currentIndex = searchedLastIndex
                continue
            }
            if metaData[1] == "test" {
                testsGrouped.append(IndexableSubString(parent: rawValue, indexes: groupMetaData.startIndex..<code.endIndex))
            }
        } while (currentIndex < testsLastIndex)
        self.tests = testsGrouped.compactMap { Test(rawValue: String($0.value)) }
    }
    
}
