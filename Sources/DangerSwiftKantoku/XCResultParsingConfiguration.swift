//
//  XCResultParsingConfiguration.swift
//  
//
//  Created by 史 翔新 on 2022/02/10.
//

import Foundation

public enum ExcludedTarget: Equatable {
    case exact(String)
    case regex(String)

    func matches(string: String) -> Bool {
        switch self {
        case let .exact(needle):
            return string == needle
        case let .regex(regex):
            return string.range(of: regex, options: .regularExpression) != nil
        }
    }
}

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
    public var reportingFileType: ReportingFileType

    // code coverage
    public var codeCoverageRequirement: CodeCoverageRequirement
    public var excludeCoverageTarget: [ExcludedTarget]
    public var excludeCoverageForFiles: ((RelativeFilePath) -> Bool)
    public var failIfCoverageUnavailable: Bool
    public var showCoverageForChangedFiles: Bool

    public init(
        parseBuildWarnings: Bool = true,
        parseBuildErrors: Bool = true,
        parseAnalyzerWarnings: Bool = true,
        parseTestFailures: Bool = true,
        reportingFileType: ReportingFileType = .all,
        shouldFailIfCoverageUnavailable: Bool = false,
        codeCoverageRequirement: CodeCoverageRequirement = .required(.init(acceptable: 0, recommended: 0.6)),
        excludeCoverageTarget: [ExcludedTarget] = [],
        excludeCoverageForFiles: @escaping ((RelativeFilePath) -> Bool) = { _ in return false },
        showCoverageForChangedFiles: Bool = true
    ) {
        self.parseBuildWarnings = parseBuildWarnings
        self.parseBuildErrors = parseBuildErrors
        self.parseAnalyzerWarnings = parseAnalyzerWarnings
        self.parseTestFailures = parseTestFailures
        self.reportingFileType = reportingFileType
        
        self.codeCoverageRequirement = codeCoverageRequirement
        self.failIfCoverageUnavailable = shouldFailIfCoverageUnavailable
        self.excludeCoverageTarget = excludeCoverageTarget
        self.excludeCoverageForFiles = excludeCoverageForFiles
        self.showCoverageForChangedFiles = showCoverageForChangedFiles
        
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
