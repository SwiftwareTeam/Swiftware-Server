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

    func testCreateResponse() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

        let surveyResponse = SurveyResponse(uid: "u00", surveyID: 1, responseType: "new", responses: [1: 1, 2: 1, 3: nil])

        try app.test(.POST, "createResponse", beforeRequest: { req in
            try req.content.encode(surveyResponse)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .created)
        })

        if let responseFromController = try? app.dataController?.getSurveyResponse(id: surveyResponse.id) {
            XCTAssertEqual(responseFromController, surveyResponse)
        }

        try app.test(.POST, "createResponse", beforeRequest: { req in
            try req.content.encode("Some Random String")
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .badRequest)

        })
    }

    func testUpdateResponse() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)
        let sampleData = SampleData()

        var surveyResponse = sampleData.response

        try app.test(.POST, "createResponse", beforeRequest: { req in
            try req.content.encode(surveyResponse)
        }, afterResponse: { resp in
            XCTAssertEqual(resp.status, .created)
        })

        surveyResponse.responses[1] = nil
        surveyResponse.responses[2] = 3

        try app.test(.PATCH, "updateResponse", beforeRequest: { req in
            try req.content.encode(surveyResponse)
        }, afterResponse: { resp in
            XCTAssertEqual(resp.status, .ok)
        })

        if let survey = try app.dataController?.getSurveyResponse(id: surveyResponse.id) {
            XCTAssertEqual(survey.responses[1], nil)
            XCTAssertEqual(survey.responses[2], 3)
        } else {
            XCTFail()
        }

    }
    
    func testDeleteResponse() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)
        let sampleData = SampleData()

        let surveyResponse = sampleData.response

        try app.test(.POST, "createResponse", beforeRequest: { req in
            try req.content.encode(surveyResponse)
        })

        try app.test(.DELETE, "deleteResponse", beforeRequest: { req in
            try req.content.encode(surveyResponse)
        }, afterResponse: { resp in
            XCTAssertEqual(resp.status, .ok)
        })

        let responseInDatabase: SurveyResponse? = try  app.dataController?.getSurveyResponse(id: surveyResponse.id)
        XCTAssertNil(responseInDatabase)
    }
    func testBackup() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

        try app.test(.GET, "backup", afterResponse: { resp in
            XCTAssertEqual(resp.status, .ok)
        })

    }
    func testLoadBackup() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

        try app.test(.GET, "loadBackup", afterResponse: { resp in
            XCTAssertEqual(resp.status, .ok)
        })
    }

    func testAvgResponseRate() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

        try app.test(.GET, "avgResponseRate/1", afterResponse: { resp in
            XCTAssertEqual(resp.status, .ok)
        })
    }
}
