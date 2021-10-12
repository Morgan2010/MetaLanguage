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
