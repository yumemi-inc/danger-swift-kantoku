//
//  DocumentLocationTests.swift
//  
//
//  Created by 史 翔新 on 2022/02/10.
//

import XCTest
import XCResultKit
@testable import DangerSwiftKantoku

final class DocumentLocationTests: XCTestCase {
    
    func test_relativePath() {
        
        let errorRecord = ActionsInvocationRecord.errorFile()!
        let fileThatProducedError = errorRecord.issues.errorSummaries[0].documentLocationInCreatingWorkspace!
        assert(fileThatProducedError.url == "file:///Users/me/Documents/YUMEMI/Projects/sample/Main/SceneDelegate.swift#CharacterRangeLen=0&EndingColumnNumber=26&EndingLineNumber=21&StartingColumnNumber=26&StartingLineNumber=21")
        
        let basePath = "/Users/me/Documents/YUMEMI/Projects/sample"
        let expectedRelativePath = "Main/SceneDelegate.swift"
        let expectedQueries = DocumentLocation.FileQueries(startingLineNumber: 21, startingColumnNumber: 26, endingLineNumber: 21, endingColumnNumber: 26, characterRangeLen: 0)
        let result = fileThatProducedError.relativePath(against: basePath)
        XCTAssertEqual(result.filePath, expectedRelativePath)
        XCTAssertEqual(result.queries, expectedQueries)
        
    }
    
}
