//
//  DocumentLocation+.swift
//  DangerSwiftKantoku
//
//  Created by 史 翔新 on 2022/02/10.
//

import Foundation
import XCResultKit

extension DocumentLocation {
    
    struct FileQueries: Equatable {
        var startingLineNumber: Int?
        var startingColumnNumber: Int?
        var endingLineNumber: Int?
        var endingColumnNumber: Int?
        var characterRangeLen: Int?
    }
    
}

extension DocumentLocation {
    
    private func regularAbsoluteFilePath(of absoluteFilePath: String) -> String {
        
        if absoluteFilePath.hasPrefix("file:///") {
            return absoluteFilePath
            
        } else if absoluteFilePath.hasPrefix("/") {
            return "file://\(absoluteFilePath)"
            
        } else {
            assertionFailure("Unconfirmed baes absolute file path pattern: \(absoluteFilePath)")
            return absoluteFilePath
        }
        
    }
    
    private func regularRelativeFilePath(of relativeFilePath: Substring) -> Substring {
        
        guard !relativeFilePath.contains(":") && !relativeFilePath.hasPrefix("//") else {
            assertionFailure("Unconfirmed baes relative file path pattern: \(relativeFilePath)")
            return relativeFilePath
        }
        
        if relativeFilePath.hasPrefix("/") {
            return relativeFilePath.dropFirst()
            
        } else {
            return relativeFilePath
        }
        
    }
    
    private func extractingQueries(from path: Substring) -> (filePath: String, queries: FileQueries?) {
        
        guard let querySeparatorIndex = path.firstIndex(where: { $0 == "#" }) else {
            return (String(path), nil)
        }
        
        let filePath = String(path[..<querySeparatorIndex])
        let queryString = path[querySeparatorIndex...].dropFirst()
        let queryItems = queryString.components(separatedBy: "&")
        let queryDictionary = queryItems.reduce(into: [String: Int]()) {
            let components = $1.components(separatedBy: "=")
            guard components.count == 2, let value = Int(components[1]) else { return }
            $0[components[0]] = value
        }
        let queries = FileQueries(
            startingLineNumber: queryDictionary["StartingLineNumber"],
            startingColumnNumber: queryDictionary["StartingColumnNumber"],
            endingLineNumber: queryDictionary["EndingLineNumber"],
            endingColumnNumber: queryDictionary["EndingColumnNumber"],
            characterRangeLen: queryDictionary["CharacterRangeLen"]
        )
        
        return (filePath, queries)
        
    }
    
    func relativePath(against baseFilePath: String) -> (filePath: String, queries: FileQueries?) {
        
        let absoluteFilePath = regularAbsoluteFilePath(of: url)
        let baseFilePath = regularAbsoluteFilePath(of: baseFilePath)
        guard absoluteFilePath.hasPrefix(baseFilePath) else {
            // The given file is outside of the repository.
            // This may happen when DerivedData path setting is not Relative.
            assert(absoluteFilePath.contains("/DerivedData/"))
            return (url, nil)
        }
        
        let relativePath = absoluteFilePath.dropFirst(baseFilePath.count)
        let regularRelativePath = regularRelativeFilePath(of: relativePath)
        let result = extractingQueries(from: regularRelativePath)
        
        return result
        
    }
    
}
