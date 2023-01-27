//
//  File.swift
//  
//
//  Created by 史 翔新 on 2022/03/03.
//

import Foundation

extension Kantoku {
    
    enum CommentLevel {
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
    
    func post(_ summaries: [PostableIssueSummary], as level: CommentLevel) {
        for summary in summaries {
            let message = summary.issueMessage
            let filePath = summary.documentLocation?.relativePath(against: workingDirectoryPath)

            if let filePath = filePath {
                let lineNumber = filePath.queries?.endingLineNumber
                // Line numbers in XCResult starts from `0`, while on web pages like GitHub starts from `1`
                post(as: .comment)(message, filePath.filePath, lineNumber.map({ $0 + 1 }) ?? 0)
            } else {
                post(as: level)(message)
            }
            
        }
        
    }

}
