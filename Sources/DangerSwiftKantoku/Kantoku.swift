//
//  Kantoku.swift
//  
//
//  Created by 史 翔新 on 2022/02/10.
//

import Foundation
import XCResultKit

public struct Kantoku {
    
    let workingDirectoryPath: String
    
    private let inlineCommentExecutor: (_ comment: String, _ filePath: String, _ lineNumber: Int) -> Void
    private let normalCommentExecutor: (_ comment: String) -> Void
    
    private let inlineWarningExecutor: (_ comment: String, _ filePath: String, _ lineNumber: Int) -> Void
    private let normalWarningExecutor: (_ comment: String) -> Void
    
    private let inlineFailureExecutor: (_ comment: String, _ filePath: String, _ lineNumber: Int) -> Void
    private let normalFailureExecutor: (_ comment: String) -> Void
    
    init(
        workingDirectoryPath: String,
        inlineCommentExecutor: @escaping (_ comment: String, _ filePath: String, _ lineNumber: Int) -> Void,
        normalCommentExecutor: @escaping (_ comment: String) -> Void,
        inlineWarningExecutor: @escaping (_ comment: String, _ filePath: String, _ lineNumber: Int) -> Void,
        normalWarningExecutor: @escaping (_ comment: String) -> Void,
        inlineFailureExecutor: @escaping (_ comment: String, _ filePath: String, _ lineNumber: Int) -> Void,
        normalFailureExecutor: @escaping (_ comment: String) -> Void
    ) {
        self.workingDirectoryPath = workingDirectoryPath
        self.inlineCommentExecutor = inlineCommentExecutor
        self.normalCommentExecutor = normalCommentExecutor
        self.inlineWarningExecutor = inlineWarningExecutor
        self.normalWarningExecutor = normalWarningExecutor
        self.inlineFailureExecutor = inlineFailureExecutor
        self.normalFailureExecutor = normalFailureExecutor
    }
    
}

extension Kantoku {
    
    func comment(_ comment: String, to filePath: String, at lineNumber: Int) {
        inlineCommentExecutor(comment, filePath, lineNumber)
    }
    
    func comment(_ comment: String) {
        normalCommentExecutor(comment)
    }
    
    func warn(_ warning: String, to filePath: String, at lineNumber: Int) {
        inlineWarningExecutor(warning, filePath, lineNumber)
    }
    
    func warn(_ warning: String) {
        normalWarningExecutor(warning)
    }
    
    func fail(_ failure: String, to filePath: String, at lineNumber: Int) {
        inlineFailureExecutor(failure, filePath, lineNumber)
    }
    
    func fail(_ failure: String) {
        normalFailureExecutor(failure)
    }
    
}

extension Kantoku {
    
    private func postIssuesIfNeeded(from resultFile: XCResultFile, configuration: XCResultParsingConfiguration) {
        
        if configuration.needsIssues {
            
            guard let issues = resultFile.getInvocationRecord()?.issues else {
                warn("Failed to get invocation record from \(resultFile.url.absoluteString)")
                return
            }
            
            if configuration.parseBuildWarnings {
                post(issues.warningSummaries, as: .warning)
            }
            
            if configuration.parseBuildErrors {
                post(issues.errorSummaries, as: .failure)
            }
            
            if configuration.parseAnalyzerWarnings {
                post(issues.analyzerWarningSummaries, as: .warning)
            }
            
            if configuration.parseTestFailures {
                post(issues.testFailureSummaries, as: .failure)
            }
            
        }
        
    }
    
    public func parseXCResultFile(at filePath: String, configuration: XCResultParsingConfiguration) {
        
        let resultFile = XCResultFile(url: .init(fileURLWithPath: filePath))
        
        postIssuesIfNeeded(from: resultFile, configuration: configuration)
        
    }
    
}
