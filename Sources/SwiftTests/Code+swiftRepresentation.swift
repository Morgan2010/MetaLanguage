//
//  File.swift
//  File
//
//  Created by Morgan McColl on 12/10/21.
//

import Foundation
import MetaLanguage
import SwiftParsing

public extension Code {
    
    /// Converts this code to generic swift code
    var swiftRepresentation: String? {
        switch self {
        case .languageCode(let code, let language):
            if language == .swift {
                return code
            }
            return nil
        default:
            return nil
        }
    }
    
    /// Converts this code into a setup function used in XCTest classes
    var swiftSetupRepresentation: String? {
        switch self {
        case .languageCode(let code, let language):
            switch language {
            case .swift:
                return "override func setUp() " + code.createBlock
            default:
                return nil
            }
        default:
            return nil
        }
    }
    
    /// Converts this code into a tearDown function used in XCTest calsses
    var swiftTearDownRepresentation: String? {
        switch self {
        case .languageCode(let code, let language):
            switch language {
            case .swift:
                return "override func tearDown() " + code.createBlock
            default:
                return nil
            }
        default:
            return nil
        }
    }
    
}
