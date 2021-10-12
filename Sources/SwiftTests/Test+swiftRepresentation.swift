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
        switch self {
        case .languageTest(let name, let code, let language):
            switch language {
            case .swift:
                return "func \(name)() " + code.createBlock
            default:
                return nil
            }
        default:
            return nil
        }
    }
    
}
