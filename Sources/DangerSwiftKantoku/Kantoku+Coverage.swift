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
    
    func post(_ coverage: CodeCoverage, as acceptanceDecision: (Double) -> CoverageAcceptance) {
        
        let formatter = coverageNumberFormatter
        let title = "Overall"
        let overallCoverage = coverage.lineCoverage
        let overallAcceptance = acceptanceDecision(overallCoverage)
        let coverageText = formatter.string(from: overallCoverage as NSNumber) ?? {
            fail("Failed to extract overall coverage from \(overallCoverage)")
            return "NaN"
        }()
        
        let markdownLines: [String] = [
            "| | Coverage | Acceptance |",
            "|:---:|:---:|:---:|",
            "| \(title) | \(coverageText) | \(overallAcceptance.markdownDescription) |",
            // TODO: Coverage of diff files
        ]
        markdown(markdownLines.joined(separator: "\n"))
        
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
