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
    let modifiedFiles: [String]
    let createdFiles: [String]

    private let markdownCommentExecutor: (_ comment: String) -> Void

    private let inlineCommentExecutor: (_ comment: String, _ filePath: String, _ lineNumber: Int) -> Void
    private let normalCommentExecutor: (_ comment: String) -> Void

    private let inlineWarningExecutor: (_ comment: String, _ filePath: String, _ lineNumber: Int) -> Void
    private let normalWarningExecutor: (_ comment: String) -> Void

    private let inlineFailureExecutor: (_ comment: String, _ filePath: String, _ lineNumber: Int) -> Void
    private let normalFailureExecutor: (_ comment: String) -> Void

    init(
        workingDirectoryPath: String,
        modifiedFiles: [String],
        createdFiles: [String],
        markdownCommentExecutor: @escaping (_ comment: String) -> Void,
        inlineCommentExecutor: @escaping (_ comment: String, _ filePath: String, _ lineNumber: Int) -> Void,
        normalCommentExecutor: @escaping (_ comment: String) -> Void,
        inlineWarningExecutor: @escaping (_ comment: String, _ filePath: String, _ lineNumber: Int) -> Void,
        normalWarningExecutor: @escaping (_ comment: String) -> Void,
        inlineFailureExecutor: @escaping (_ comment: String, _ filePath: String, _ lineNumber: Int) -> Void,
        normalFailureExecutor: @escaping (_ comment: String) -> Void
    ) {
        self.workingDirectoryPath = workingDirectoryPath
        self.modifiedFiles = modifiedFiles
        self.createdFiles = createdFiles
        self.markdownCommentExecutor = markdownCommentExecutor
        self.inlineCommentExecutor = inlineCommentExecutor
        self.normalCommentExecutor = normalCommentExecutor
        self.inlineWarningExecutor = inlineWarningExecutor
        self.normalWarningExecutor = normalWarningExecutor
        self.inlineFailureExecutor = inlineFailureExecutor
        self.normalFailureExecutor = normalFailureExecutor
    }
}

extension Kantoku {
    func markdown(_ comment: String) {
        markdownCommentExecutor(comment)
    }

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
                let filteredSummaries = summaries(of: issues.warningSummaries, filteredBy: configuration.reportingFileType)
                post(filteredSummaries, as: .warning)
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

    private func postCoverageIfNeeded(from resultFile: XCResultFile, configuration: XCResultParsingConfiguration) {
        if let coverageAcceptanceDecision = configuration.codeCoverageRequirement.acceptanceDecision {
            guard let coverage = resultFile.getCodeCoverage() else {
                if configuration.failIfCoverageUnavailable {
                    fail("Failed to get coverage from \(resultFile.url.absoluteString)")
                } else {
                    warn("Failed to get coverage from \(resultFile.url.absoluteString)")
                }

                return
            }
            let excludeCoverageTarget = configuration.excludeCoverageTarget + [.regex("*Tests$")]
            var relaventTestCoverage = coverage.filterTargets(excludedTargets: excludeCoverageTarget)
            relaventTestCoverage = coverage.filterTarget(excludeFiles: configuration.excludeCoverageForFiles)
            let files: [XCResultParsingConfiguration.RelativeFilePath]
            if configuration.showCoverageForChangedFiles {
                files = (createdFiles + modifiedFiles)

            } else {
                files = []
            }
            post(relaventTestCoverage, for: files, as: coverageAcceptanceDecision)
        }
    }

    public func parseXCResultFile(at filePath: String, configuration: XCResultParsingConfiguration) {
        let resultFile = XCResultFile(url: .init(fileURLWithPath: filePath))

        postIssuesIfNeeded(from: resultFile, configuration: configuration)
        postCoverageIfNeeded(from: resultFile, configuration: configuration)
    }
}

extension XCResultParsingConfiguration.CodeCoverageRequirement {
    var acceptanceDecision: ((Double) -> Kantoku.CoverageAcceptance)? {
        switch self {
        case .none:
            return nil

        case .required(let threshold):
            return { coverage in
                if coverage >= threshold.recommended {
                    return .good
                } else if coverage >= threshold.acceptable {
                    return .acceptable
                } else {
                    return .reject
                }
            }
        }
    }
}

extension Kantoku {
    private func summaries<T: PostableIssueSummary>(of summaries: [T], filteredBy fileType: XCResultParsingConfiguration.ReportingFileType) -> [T] {
        let filteringPredicate: (XCResultParsingConfiguration.RelativeFilePath) -> Bool

        switch fileType {
        case .all:
            return summaries

        case .modifiedAndCreatedFiles:
            filteringPredicate = { (modifiedFiles + createdFiles).contains($0) }

        case .custom(predicate: let predicate):
            filteringPredicate = predicate
        }

        return summaries.filter { summary in
            guard let relativePath = summary.documentLocation?.relativePath(against: workingDirectoryPath) else {
                return false
            }
            return filteringPredicate(relativePath.filePath)
        }
    }
}

extension Kantoku {

    private func summaries<T: PostableIssueSummary>(of summaries: [T], filteredBy fileType: XCResultParsingConfiguration.ReportingFileType) -> [T] {

        let filteringPredicate: (XCResultParsingConfiguration.RelativeFilePath) -> Bool

        switch fileType {
        case .all:
            return summaries

        case .modifiedAndCreatedFiles:
            filteringPredicate = { (modifiedFiles + createdFiles).contains($0) }

        case .custom(predicate: let predicate):
            filteringPredicate = predicate
        }

        return summaries.filter { summary in
            guard let relativePath = summary.documentLocation?.relativePath(against: workingDirectoryPath) else {
                return false
            }
            return filteringPredicate(relativePath.filePath)
        }

    }

}
