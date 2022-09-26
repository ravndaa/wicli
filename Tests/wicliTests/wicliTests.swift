import XCTest
@testable import wicli

final class wicliTests: XCTestCase {
    func testPower() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        let asd = try XCTUnwrap(wicli.Power.parse(["en0","off"]))
        XCTAssertEqual(asd.interface, "en1")
        XCTAssertEqual(asd.state.rawValue, "off")

    }
}
