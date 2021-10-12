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
    
    var swiftRepresentation: String? {
        let mutator = StringMutator()
        switch self {
        case .languageTest(let name, let code, let language):
            switch language {
            case .swift:
                return "func \(name)() " + mutator.createBlock(for: code)
            default:
                return nil
            }
        default:
            return nil
        }
    }
    
}
