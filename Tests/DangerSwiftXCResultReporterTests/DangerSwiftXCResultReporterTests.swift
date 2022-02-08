import XCTest
@testable import DangerSwiftXCResultReporter

final class danger_swift_xcresult_reporterTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(DangerSwiftXCResultReporter().text, "Hello, World!")
    }
}
