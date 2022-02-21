//
//  ActionsInvocationRecord+.swift
//  
//
//  Created by 史 翔新 on 2022/02/10.
//

import Foundation
import XCResultKit

extension ActionsInvocationRecord {
    
    private static var absoluteURL: URL {
        URL(fileURLWithPath: #file)
            .deletingLastPathComponent()
            .appendingPathComponent("Resources")
    }
    
    private static var errorFileURL: URL {
        absoluteURL.appendingPathComponent("Test_Errors.json")
    }
    
    private static var warningFileURL: URL {
        absoluteURL.appendingPathComponent("Test_Warnings.json")
    }
    
    private static var perfectFileURL: URL {
        absoluteURL.appendingPathComponent("Test_Perfect.json")
    }
    
    private init?(url: URL) {
        do {
            let data = try Data(contentsOf: url)
            guard let rootJSON = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject] else {
                assertionFailure("Expecting top level dictionary but didn't find one")
                return nil
            }
            self.init(rootJSON)
            
        } catch {
            assertionFailure("Error deserializing JSON: \(error)")
            return nil
        }
    }
    
}

extension ActionsInvocationRecord {
    
    static func errorFile() -> ActionsInvocationRecord? {
        .init(url: errorFileURL)
    }
    
    static func warningFile() -> ActionsInvocationRecord? {
        .init(url: warningFileURL)
    }
    
    static func perfectFile() -> ActionsInvocationRecord? {
        .init(url: perfectFileURL)
    }
    
}
