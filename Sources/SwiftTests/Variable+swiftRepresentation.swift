//
//  File.swift
//  File
//
//  Created by Morgan McColl on 12/10/21.
//

import Foundation
import MetaLanguage

public extension Variable {
    
    /// Converts into a swift variable
    var swiftRepresentation: String? {
        switch self {
        case .languageVariable(let declaration, let language):
            switch language {
            case .swift:
                return declaration
            default:
                return nil
            }
        }
    }
    
}
