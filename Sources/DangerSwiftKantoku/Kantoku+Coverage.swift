//
//  Kantoku+Coverage.swift
//
//
//  Created by 史 翔新 on 2022/03/03.
//

import Foundation
import XCResultKit

extension Kantoku {
    var coverageNumberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 2
        return formatter
    }
}

extension Kantoku {
    enum CoverageAcceptance {
        case good
        case acceptable
        case reject
    }

    private struct CoverageCommentItem {
        var title: String
        var coverage: Double
        var acceptance: CoverageAcceptance
    }

    func post(_ coverage: CodeCoverage, for files: [XCResultParsingConfiguration.RelativeFilePath], as acceptanceDecision: (Double) -> CoverageAcceptance) {
        let formatter = coverageNumberFormatter
        let overallCoverageText = formatter.string(from: coverage.lineCoverage as NSNumber) ?? {
            warn("Failed to extract overall coverage, line coverage \(coverage.lineCoverage)")
            return "NaN"
        }()
        let overallAcceptance = acceptanceDecision(coverage.lineCoverage)
        var markdownLines: [String] = ["##Overall Coverage",
                                       "\(overallCoverageText)    \(overallAcceptance.markdownDescription)"]

        markdownLines.append("")
        coverage.targets.forEach { target in
            let filtered = target.filteringFiles(on: files)
            if filtered.files.count > 0 {
                markdownLines.append("")
                let acceptance = acceptanceDecision(target.lineCoverage)
                let coverageText = formatter.string(from: target.lineCoverage as NSNumber) ?? "NaN"
                markdownLines.append(contentsOf: ["| ###\(target.name) | \(coverageText) | \(acceptance.markdownDescription) |",
                                                  ""])
                markdownLines.append(contentsOf: ["| File | Coverage | Acceptance |",
                                                  "|:---:|:---:|:---:|"])
                filtered.files.forEach {
                    let acceptance = acceptanceDecision($0.lineCoverage)
                    let coverageText = formatter.string(from: $0.lineCoverage as NSNumber) ?? "NaN"
                    markdownLines.append("| \($0.name) | \(coverageText) | \(acceptance.markdownDescription) |")
                }
            }
        }

        markdown(markdownLines.joined(separator: "\n"))
        switch overallAcceptance {
        case .good:
            break

        case .acceptable:
            warn("Overall coverage is \(coverage.lineCoverage)")

        case .reject:
            fail("Overall coverage is \(coverage.lineCoverage), which is not enough")
        }
    }
}

extension CodeCoverage {
    func filterTargets(excludedTargets: [ExcludedTarget]) -> CodeCoverage {
        let targets = self.targets.filter { target in
            !target.files.isEmpty && !excludedTargets.contains {
                $0.matches(string: target.name)
            }
        }
        return CodeCoverage(targets: targets)
    }

    func filterTarget(excludeFiles: (XCResultParsingConfiguration.RelativeFilePath) -> Bool) -> CodeCoverage {
        let targets = self.targets
            .map { $0.filteringFiles(excludeFiles: excludeFiles) }
            .filter { target in
                !target.files.isEmpty
            }
        return CodeCoverage(targets: targets)
    }

    func filteringTargets(on files: [String]) -> CodeCoverage {
        let targets = self.targets
            .map { $0.filteringFiles(on: files) }
            .filter { target in
                !target.files.isEmpty
            }
        return CodeCoverage(targets: targets)
    }
}

extension CodeCoverageTarget {
    func filteringFiles(on files: [String]) -> CodeCoverageTarget {
        let files = self.files.filter { files.contains($0.path) }
        return CodeCoverageTarget(name: name, buildProductPath: buildProductPath, files: files)
    }

    func filteringFiles(excludeFiles: (XCResultParsingConfiguration.RelativeFilePath) -> Bool) -> CodeCoverageTarget {
        let files = self.files.filter { excludeFiles($0.path) }
        return CodeCoverageTarget(name: name, buildProductPath: buildProductPath, files: files)
    }
}

extension Kantoku.CoverageAcceptance {
    var markdownDescription: String {
        switch self {
        case .good:
            return ":white_flower:"

        case .acceptable:
            return ":thinking:"

        case .reject:
            return ":no_good:"
        }
    }
}
