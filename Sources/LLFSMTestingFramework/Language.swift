//
//  File.swift
//  File
//
//  Created by Morgan McColl on 9/10/21.
//

import Foundation

enum Language {
    
    case swift
    
    init?(rawValue: String) {
        if rawValue == "swift" {
            self = .swift
            return
        }
        return nil
    }
    
}
