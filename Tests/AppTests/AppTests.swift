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

        let surveyResponse = SurveyResponse(uid: "u00",
                                            surveyID: 1,
                                            responseType: "new",
                                            responses: [1: 1, 2: 1, 3: nil])

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

//        surveyResponse.responses[1] = nil
        surveyResponse.responses.updateValue(nil, forKey: 1)
        surveyResponse.responses[2] = 3

        try app.test(.PATCH, "updateResponse", beforeRequest: { req in
            try req.content.encode(surveyResponse)
        }, afterResponse: { resp in
            XCTAssertEqual(resp.status, .ok)
        })

        if let survey = try app.dataController?.getSurveyResponse(id: surveyResponse.id) {

            XCTAssertEqual(survey.responses[1] ?? nil, nil)
            XCTAssertEqual(survey.responses[2], 3)
        } else {
            XCTFail("Unable to load surveyResponses after creating them")
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
        app.dataController?.calculateAllResponseRates()

        var oldCharts: [ChartData]?
        var newCharts: [ChartData]?

        try app.test(.GET, "deprecated/avgResponseRate/3", afterResponse: { resp in
            XCTAssertEqual(resp.status, .ok)
            oldCharts = try resp.content.decode([ChartData]?.self)
        })

        try app.test(.GET, "avgResponseRate/3", afterResponse: { resp in
            XCTAssertEqual(resp.status, .ok)
            newCharts = try resp.content.decode([ChartData]?.self)
        })

        guard let unwrappedOldCharts: [ChartData] = oldCharts else {
            XCTFail("Old Charts should not be null")
            return
        }
        guard let unwrappedNewCharts: [ChartData] = newCharts else {
            XCTFail("New Charts should not be null")
            return
        }

        for (oldChart, newChart) in zip(unwrappedOldCharts, unwrappedNewCharts) {
            for (oldMeasureVal, newMeasureVal) in zip(oldChart.measureValues, newChart.measureValues) {
                let oldRounded = Double(round(oldMeasureVal * 1000)) / 1000.0
                let newRounded = Double(round(newMeasureVal * 1000)) / 1000.0
                XCTAssertEqual(oldRounded, newRounded)
            }
        }
    }

    // TODO: Implement Tests for Personlity Scores Endpoint
    func testPersonalityScores() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)
        var sampleScore = PersonalityScore(surveyID: 1,
                                           userID: "u00",
                                           responseID: UUID(),
                                           categories: ["Extraversion",
                                                        "Agreeableness",
                                                        "Conscientiousness",
                                                        "Neuroticism",
                                                        "Openness"],
                                           scores: [0.625, 0.7, 0.75, 0.85, 0.4])

        if let score = try app.dataController?.personalityScore(forUser: "u00") {
            sampleScore.scores = score.scores
            XCTAssertEqual(sampleScore.surveyID, score.surveyID)
            XCTAssertEqual(sampleScore.userID, score.userID)
            XCTAssertEqual(sampleScore.categories, score.categories)
            XCTAssertEqual(sampleScore.scores, score.scores)

        } else {
            XCTFail("Unable to create personality score for user u00")
        }

        }
}
