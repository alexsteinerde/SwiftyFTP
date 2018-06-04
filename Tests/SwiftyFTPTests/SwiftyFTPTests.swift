import XCTest
@testable import SwiftyFTP

final class SwiftyFTPTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        let expect = expectation(description: "FTP Download")
        var configuration = SessionConfiguration()
        configuration.host = "ftp://momentmap.de"
        configuration.username = "89304f69560"
        configuration.password = "Kleiderbugel8Lampe"
        let session = Session(configuration: configuration)
        let url = URL(fileURLWithPath: "/Users/alex/Desktop/Handelsregister Eintragung 3. Jun 2018 .pdf")
        let path = "/htdocs/momentmap-backups/test.pdf"
        session.upload(url, path: path) {
            (result, error) -> Void in
            print("Upload file with result:\n\(result), error: \(error)\n\n")
            expect.fulfill()
        }
        wait(for: [expect], timeout: 60)
    }


    static var allTests = [
        ("testExample", testExample),
    ]
}
