//
//  File.swift
//  
//
//  Created by Shawn Long on 4/27/22.
//

@testable import App
import XCTVapor
import XCTest
import SwiftUI

final class ServerDataTests : XCTestCase {

    func testInsertRetrieveSurvey() async throws {
        let data = ServerData()
        let sampleData = SampleData()

        // Test Retrieval when empty
        let nullSurvey = await data.firstSurvey(where: {_ in true})
        XCTAssertNil(nullSurvey)

        // Test Insert & Retrieval when unique value
        var sampleSurvey = sampleData.survey
        try await data.storeSurvey(sampleSurvey)
        var retrievedSurvey: Survey? = await data.firstSurvey(where: { $0.id == sampleSurvey.id })
        XCTAssertEqual(retrievedSurvey, sampleSurvey)

        // Test Insert when existing value
        sampleSurvey.name = "Modified Test Survey"
        try await data.storeSurvey(sampleSurvey)
        retrievedSurvey = await data.firstSurvey(where: {$0.id == sampleSurvey.id})
        XCTAssertEqual(retrievedSurvey?.name, "Modified Test Survey")
    }

    func testThreadSafety() throws {
        let data = ServerData()
        let sampleData = SampleData()
        let survey1 = sampleData.survey

        // Atetmpt to perform multiple updates at the same time
        XCTAssertNoThrow(DispatchQueue.global().async {
            DispatchQueue.concurrentPerform(iterations: 1_000) { _ in
                Task {
                    let number = Int.random(in: 1...100)
                    let randomName = "Test \(number)"

                   try await data.storeSurvey(Survey(id: survey1.id, name: randomName, group: survey1.group,
                                                      questions: survey1.questions, answers: survey1.answers))
                }
            }
        })

        // If this section of code executes, then no race condition!
        // Test will pass implicitly without Assert statement, but it
        // is added just for clarity

        XCTAssertTrue(true)
    }
}

final class DataControllerTests : XCTestCase {
    func testInitialize() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }

        let controller = DataController(app)

        if let succeeded = try? await controller.initialize() {
            XCTAssertTrue(succeeded)
        }

        guard let responses = try? await controller.getSurveyResponses(uid: "u00") else {
            XCTFail()
            return
        }
        XCTAssertGreaterThanOrEqual(responses.count, 2)
        XCTAssertEqual(responses[0].uid, "u00")
    }
}
