//
//  File.swift
//  File
//
//  Created by Morgan McColl on 12/10/21.
//

import Foundation
import MetaLanguage
import SwiftParsing

extension Code {
    
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
        let mutator = StringMutator()
        switch self {
        case .languageCode(let code, let language):
            switch language {
            case .swift:
                return "override func setUp() " + mutator.createBlock(for: code)
            default:
                return nil
            }
        default:
            return nil
        }
    }
    
    var swiftTearDownRepresentation: String? {
        let mutator = StringMutator()
        switch self {
        case .languageCode(let code, let language):
            switch language {
            case .swift:
                return "override func tearDown() " + mutator.createBlock(for: code)
            default:
                return nil
            }
        default:
            return nil
        }
    }
    
}
