//
//  File.swift
//  File
//
//  Created by Morgan McColl on 9/10/21.
//

import Foundation

public enum Language {
    
    case swift
    
    public init?(rawValue: String) {
        if rawValue == "swift" {
            self = .swift
            return
        }
        return nil
    }
    
}

extension Language: Codable {}
