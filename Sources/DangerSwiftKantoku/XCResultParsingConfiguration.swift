//
//  XCResultParsingConfiguration.swift
//  
//
//  Created by 史 翔新 on 2022/02/10.
//

import Foundation

public struct XCResultParsingConfiguration {
    
    public var parseBuildWarnings: Bool
    public var parseBuildErrors: Bool
    public var parseAnalyzerWarnings: Bool
    public var parseTestFailures: Bool
    
    public init(
        parseBuildWarnings: Bool = true,
        parseBuildErrors: Bool = true,
        parseAnalyzerWarnings: Bool = true,
        parseTestFailures: Bool = true
    ) {
        self.parseBuildWarnings = parseBuildWarnings
        self.parseBuildErrors = parseBuildErrors
        self.parseAnalyzerWarnings = parseAnalyzerWarnings
        self.parseTestFailures = parseTestFailures
    }
    
}

extension XCResultParsingConfiguration {
    
    public static var `default`: XCResultParsingConfiguration {
        .init()
    }
    
}

extension XCResultParsingConfiguration {
    
    public var needsIssues: Bool {
        parseBuildWarnings || parseBuildErrors || parseAnalyzerWarnings || parseTestFailures
    }
    
}
