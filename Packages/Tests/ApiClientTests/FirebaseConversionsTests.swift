// Created by Jimmy Yue in 2024

import XCTest
import CustomDump
import SharedModels
@testable import ApiClient

class FirebaseConversionsTests: XCTestCase {
    func testEncode() {
        var mockMessage = Message.mockUserMessage()
        let result = firebaseEncode(mockMessage)
        let expected: [String: Any] = [
            "content": "Sample message from user",
            "role": "user"
        ]
        XCTAssertNotNil(result)
        XCTAssertNoDifference(result! as NSObject, expected as NSObject)
    }
}
