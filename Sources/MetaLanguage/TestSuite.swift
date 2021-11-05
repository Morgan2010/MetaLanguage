//
//  File.swift
//  File
//
//  Created by Morgan McColl on 9/10/21.
//

import Foundation
#if os(Linux) && canImport(Foundation) && !NO_FOUNDATION
import IO
#endif
import SwiftParsing

/// A struct representing an abstract notion of a TestSuite. A TestSuite is an object containing many tests, a setup function,
/// a teardown function, and some variables.
public struct TestSuite: CustomStringConvertible {
    
    /// The name of the Test Suite
    public var name: String
    
    /// The variables in the Test Suite
    public var variables: [Variable]?
    
    /// The setup code for the TestSuite. This should run before every Test.
    public var setup: Code?
    
    /// The teardown code that will run after every Test.
    public var tearDown: Code?
    
    /// The tests in this Test Suite
    public var tests: [Test]
    
    public var wrapper: FileWrapper? {
        guard let data = description.data(using: .utf8) else {
            return nil
        }
        let wrapper = FileWrapper(regularFileWithContents: data)
        wrapper.preferredFilename = "\(self.name).swift"
        return wrapper
    }
    
    /// Create a TestSuite from previously parsed data.
    /// - Parameters:
    ///   - name: The name of the TestSuite
    ///   - tests: The tests in the TestSuite
    ///   - variables: The variables in the TestSuite
    ///   - setup: The setup code within the setup function
    ///   - tearDown: The teardown code within the teardown function
    public init(name: String, tests: [Test], variables: [Variable]? = nil, setup: Code? = nil, tearDown: Code? = nil) {
        self.name = name
        self.tests = tests
        self.setup = setup
        self.variables = variables
        self.tearDown = tearDown
    }
    
    /// Create a TestSuite from a raw string.
    public init?(rawValue: String) {
        guard let subString = rawValue.findIndexes(for: "TestSuite") else {
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
            let testsRaw = desirables.findSubString(between: "{", and: "}"),
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
        while currentIndex < testsLastIndex {
            let groupMetaData = rawValue.findSubString(after: currentIndex, with: ["@"], and: ["{", "@", "}"])
            guard
                let metaData = groupMetaData?.value.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: .whitespacesAndNewlines),
                let codeFirstIndex = groupMetaData?.lastIndex,
                let code = rawValue.findSubString(after: codeFirstIndex, with: "{", and: "}"),
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
                guard let nextKeyword = rawValue.findSubString(after: codeFirstIndex, with: ["@"], and: ["{", "@"]) else {
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
                   + String(code.value).trimmingCharacters(in: .newlines).removeRedundentIndentation.createBlock)
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

    /// Reads the contents of a regular file wrapper and generates the TestSuite using the Meta Language syntax.
    public init?(wrapper: FileWrapper) {
        guard 
            wrapper.isRegularFile,
            let codeData = wrapper.regularFileContents,
            let code = String(data: codeData, encoding: .utf16)
        else {
            return nil
        }
        self.init(rawValue: code)
    }

    /// A meta language representation of this test suite
    public var description: String {
        let vars = variables == nil ? "" : variables!.map(\.description).joined(separator: "\n")
        let testCode = tests.map(\.description).joined(separator: "\n\n")
        return "TestSuite \(name) " + 
            vars.joinWithNewLines(str2: setupCode, amount: 2)
                .joinWithNewLines(str2: tearDownCode, amount: 2)
                .joinWithNewLines(str2: testCode, amount: 2)
                .createBlock()

    }

    private var setupCode: String {
        prependCode(keyWord: "setup", code: setup)   
    }

    private var tearDownCode: String {
        prependCode(keyWord: "teardown", code: tearDown)
    }

    private func prependCode(keyWord: String, code: Code?) -> String {
        guard let code = code else {
            return ""
        }
        switch code {
        case .languageCode(_, let language):
            return "@\(language.description) \(keyWord) " + code.description.createBlock
        }
    }
    
}

extension TestSuite: Codable, Equatable, Hashable {}
