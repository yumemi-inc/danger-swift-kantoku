//
//  PostableIssueSummary.swift
//  
//
//  Created by 史 翔新 on 2022/02/15.
//

import Foundation
import XCResultKit

protocol PostableIssueSummary {
    
    var issueMessage: String { get }
    var documentLocation: DocumentLocation? { get }
    
}

extension IssueSummary: PostableIssueSummary {
    
    var issueMessage: String {
        message
    }
    
    var documentLocation: DocumentLocation? {
        documentLocationInCreatingWorkspace
    }
    
}

extension TestFailureIssueSummary: PostableIssueSummary {
    
    var issueMessage: String {
        "\(testCaseName) - \(message)"
    }
    
    var documentLocation: DocumentLocation? {
        documentLocationInCreatingWorkspace
    }
    
}
