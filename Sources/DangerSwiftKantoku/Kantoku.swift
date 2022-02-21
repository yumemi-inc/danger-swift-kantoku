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
    
    private enum CommentLevel {
        case comment
        case warning
        case failure
    }
    
    private func post(as level: CommentLevel) -> (_ message: String) -> Void {
        
        switch level {
        case .comment:
            return comment(_:)
            
        case .warning:
            return warn(_:)
            
        case .failure:
            return fail(_:)
        }
        
    }
    
    private func post(as level: CommentLevel) -> (_ message: String, _ filePath: String, _ lineNumber: Int) -> Void {
        
        switch level {
        case .comment:
            return comment(_:to:at:)
            
        case .warning:
            return warn(_:to:at:)
            
        case .failure:
            return fail(_:to:at:)
        }
        
    }
    
    private func post(_ summaries: [PostableIssueSummary], as level: CommentLevel) {
        
        for summary in summaries {
            let message = summary.issueMessage
            let filePath = summary.documentLocation?.relativePath(against: workingDirectoryPath)
            
            if let filePath = filePath {
                let lineNumber = filePath.queries?.endingLineNumber
                // Line numbers in XCResult starts from `0`, while on web pages like GitHub starts from `1`
                post(as: level)(message, filePath.filePath, lineNumber.map({ $0 + 1 }) ?? 0)
                
            } else {
                post(as: level)(message)
            }
            
        }
        
    }
    
    public func parseXCResultFile(at filePath: String, configuration: XCResultParsingConfiguration) {
        
        let resultFile = XCResultFile(url: .init(fileURLWithPath: filePath))
        if configuration.needsIssues {
            guard let issues = resultFile.getInvocationRecord()?.issues else {
                warn("Failed to get invocation record from \(filePath)")
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
    
}
