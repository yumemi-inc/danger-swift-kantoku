//
//  DangerDSL+.swift
//  
//
//  Created by 史 翔新 on 2022/02/11.
//

import Danger

extension DangerDSL {
    
    public var kantoku: Kantoku {
        .init(
            workingDirectoryPath: utils.exec("pwd"),
            inlineCommentExecutor: { message(message: $0, file: $1, line: $2) },
            normalCommentExecutor: { message($0) },
            inlineWarningExecutor: { warn(message: $0, file: $1, line: $2) },
            normalWarningExecutor: { warn($0) },
            inlineFailureExecutor: { fail(message: $0, file: $1, line: $2) },
            normalFailureExecutor: { fail($0) }
        )
    }
    
}
