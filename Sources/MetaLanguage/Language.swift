//
//  File.swift
//  File
//
//  Created by Morgan McColl on 9/10/21.
//

import Foundation

/// An enum representing the current supported languages by this framework
public enum Language: String, CustomStringConvertible {
    
    case swift
    
    /// Convert a raw string into a language. Returns nil if the string is not supported.
    public init?(rawValue: String) {
        if rawValue == "swift" {
            self = .swift
            return
        }
        return nil
    }

    /// The meta language representation of this Language
    public var description: String {
        switch self {
        case .swift:
            return "swift"
        }
    }
    
}

extension Language: Codable, Equatable, Hashable {}

