@testable import App
import XCTVapor
import XCTest

final class AppTests: XCTestCase {
    func testHelloWorld() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

        try app.test(.GET, "hello", afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.body.string, "Hello, world!")
        })
    }

    func testCreateResponse() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

        let surveyResponse = SurveyResponse(uid: "u00", surveyID: 1, responseType: "new", responses: [1: 1, 2: 1, 3: nil])

        try app.test(.POST, "createResponse", beforeRequest: { req in
            try req.content.encode(surveyResponse)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .created)
            // FIXME
//            let responseInData: SurveyResponse? = app.data?.surveyResponses.first(where: {$0.id == surveyResponse.id})
//
//            XCTAssertNotNil(responseInData)
//            XCTAssertEqual(surveyResponse, responseInData)
        })

        try app.test(.POST, "createResponse", beforeRequest: { req in
            try req.content.encode("Some Random String")
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .badRequest)

        })


    }
}
