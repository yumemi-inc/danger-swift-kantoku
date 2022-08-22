//
//  XCResultParsingConfiguration.swift
//  
//
//  Created by 史 翔新 on 2022/02/10.
//

import Foundation

public struct XCResultParsingConfiguration {

    public typealias RelativeFilePath = String

    public enum ReportingFileType {
        case all
        case modifiedAndCreatedFiles
        case custom(predicate: (RelativeFilePath) -> Bool)
    }
    
    public enum CodeCoverageRequirement {
        public struct CoverageThreshold {
            public var acceptable: Double
            public var recommended: Double
            public init(acceptable: Double, recommended: Double) {
                self.acceptable = acceptable
                self.recommended = recommended
            }
        }
        case none
        case required(CoverageThreshold)
    }
    
    public var parseBuildWarnings: Bool
    public var parseBuildErrors: Bool
    public var parseAnalyzerWarnings: Bool
    public var parseTestFailures: Bool
    
    public var codeCoverageRequirement: CodeCoverageRequirement
    public var reportingFileType: ReportingFileType
    
    public init(
        parseBuildWarnings: Bool = true,
        parseBuildErrors: Bool = true,
        parseAnalyzerWarnings: Bool = true,
        parseTestFailures: Bool = true,
        codeCoverageRequirement: CodeCoverageRequirement = .required(.init(acceptable: 0, recommended: 0.6)),
        reportingFileType: ReportingFileType = .all
    ) {
        self.parseBuildWarnings = parseBuildWarnings
        self.parseBuildErrors = parseBuildErrors
        self.parseAnalyzerWarnings = parseAnalyzerWarnings
        self.parseTestFailures = parseTestFailures
        self.codeCoverageRequirement = codeCoverageRequirement
        self.reportingFileType = reportingFileType
    }
    
}

extension XCResultParsingConfiguration {
    
    public static var `default`: XCResultParsingConfiguration {
        .init()
    }
    
}

extension XCResultParsingConfiguration {
    
    var needsIssues: Bool {
        parseBuildWarnings || parseBuildErrors || parseAnalyzerWarnings || parseTestFailures
    }
    
}
