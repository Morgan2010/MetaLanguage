//
//  File.swift
//  File
//
//  Created by Morgan McColl on 12/10/21.
//

import Foundation
import MetaLanguage
import SwiftParsing

public extension Test {
    
    /// Converts this into an XCTest case using swift code
    var swiftRepresentation: String? {
        switch self {
        case .languageTest(let name, let code, let language):
            switch language {
            case .swift:
                var newName = name
                if !name.starts(with: "test") {
                    newName = "test_" + name
                }
                return "func \(newName)() " + code.createBlock
            default:
                return nil
            }
        default:
            return nil
        }
    }
    
}
