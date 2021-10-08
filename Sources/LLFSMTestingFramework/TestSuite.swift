//
//  File.swift
//  File
//
//  Created by Morgan McColl on 9/10/21.
//

import Foundation
import SwiftParsing

struct TestSuite {
    
    var name: String
    
    var variables: [Variable]
    
    var setup: Code
    
    var tests: [Test]
    
}
