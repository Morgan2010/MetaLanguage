//
//  File.swift
//  File
//
//  Created by Morgan McColl on 9/10/21.
//

import Foundation
import XCTest
@testable import LLFSMTestingFramework

final class LanguageTests: XCTestCase {
    
    func testWorks() {
        let language = Language(rawValue: "swift")
        XCTAssertNotNil(language)
        switch language! {
        case .swift:
            XCTAssertTrue(true)
        default:
            XCTAssertTrue(false)
        }
    }
    
}
