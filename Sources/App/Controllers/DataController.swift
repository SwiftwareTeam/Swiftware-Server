//
//  ServerData.swift
//  
//
//  Created by Shawn Long on 4/17/22.
//

import Vapor
import Foundation

enum DataControllerError : Error {
    case FileError(message: String)
    case StorageError(message: String)
}

class DataController {

    private let data = ServerData()
    private let fileController: FileController
    private let app: Application
    
    //let JSONdata = try surveyEncoder.encode(surveys)
    init(_ app: Application) {
        self.app = app
        self.fileController = FileController(app)

        do {
            let surveys = [
                try fileController.loadSurvey(id: 1, name: "Big Five", group: "I see myself as"),
                try fileController.loadSurvey(id: 2, name: "Flourishing Scale", group: "Flourishing Scale"),
                try fileController.loadSurvey(id: 3, name: "Loneliness Scale", group: "Loneliness Scale"),
                try fileController.loadSurvey(id: 4, name: "Positive and Negative Affect Schedule", group: "PANAS"),
                try fileController.loadSurvey(id: 5, name: "Perceived Stress Scale", group: "In the last month how often have you been"),
                try fileController.loadSurvey(id: 6, name: "Patient Health Questionnaire-9", group: "PHQ-9")
            ]

            for surveyID in 1...surveys.count  {
                guard let _ = try? data.storeSurvey(surveys[surveyID - 1]) else { return }
                let responses = try fileController.loadResponses(surveyID: surveyID)
                guard let _ = try? data.writeSurveyResponses(responses) else { return }
            }

            let _ = try backup()
            app.logger.info("Successfully Loaded Survey Data and Responses")

        } catch let error {
            app.logger.report(error: error)
        }
    }

//    /**
//     This function begins the process of reading survey files and updating the ServerData Actor
//     - Returns: Bool representing if reading and storing succeeded
//     */
//    func initialize() async throws -> Bool {
//
//        // Load Survey 1
//
//
//        return true
//    }

    func getSurveyResponses(uid: String) throws -> [SurveyResponse] {
        return data.filterSurveyResponses({$0.uid == uid})
    }

    func getSurveyResponse(id: UUID) throws -> SurveyResponse? {
        return data.firstSurveyResponse(where: {$0.id == id})
    }

    func getSurveys() throws -> [Survey] {
        return data.filterSurveys({_ in true})
    }

    func createResponse(response: SurveyResponse) throws -> Bool {
        return try data.storeSurveyResponse(response)
    }

    func updateResponse(response: SurveyResponse) throws -> Bool {
        return try data.storeSurveyResponse(response)
    }

    func deleteResponse(id: UUID) throws -> Bool {
        app.logger.critical("Data Controller: Atetmpting to delete")
        return data.deleteSurveyResponse(id: id)
    }

    func backup() throws -> Bool {
        app.logger.info("Getting list of surveys and responses")
        let surveys =  data.filterSurveys({ _ in true })
        let surveyResponses = data.filterSurveyResponses({ _ in true })
        let snapshot = DataSnapshot(surveys: surveys, surveyResponses: surveyResponses)
        app.logger.info("Snapshot Created")

        if let success = try? fileController.backup(snapshot: snapshot) {
            return success
        } else { return false}
    }

    func loadBackup() throws -> Bool {
        if let snapshot = fileController.getBackup() {

            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US")
            app.logger.info("Loading snapshot from \(dateFormatter.string(from: snapshot.date))")

            if let responseSuccess = try? data.writeSurveyResponses(snapshot.surveyResponses) {
                if let surveySuccess = try? data.writeSurveys(snapshot.surveys) {
                    return responseSuccess && surveySuccess
                }
            }
        }
        return false
    }

    func avgResponseRate(surveyID: Int) -> [ChartData]? {
        let responses = data.filterSurveyResponses() { $0.surveyID == surveyID && $0.responseType == "post" }
        guard let survey = data.firstSurvey(where: {$0.id == surveyID}) else { return nil }
        let questionCount = survey.questions.count
        let answerCount = survey.answers.count


        var counts = Dictionary(uniqueKeysWithValues: survey.answers.map { ($0.key, 0.0)})
        var charts = [ChartData]()

        for questionID in 1 ... questionCount {
            counts = Dictionary(uniqueKeysWithValues: survey.answers.map { ($0.key, 0.0)})
            for response in responses {
                if let answerChoice = response.responses[questionID] {
                    counts[answerChoice!]! += 1.0
                }
            }
            let responseCount = responses.filter { $0.responses[questionID] != nil }.count
            for answerID in 1 ... answerCount {
                counts[answerID] = 100.0 * (counts[answerID]! / Double(responseCount))
            }

            let sortedCounts = counts.sorted(by: <)
            charts.append(ChartData(surveyID: surveyID, questionID: questionID,
                            dimensionName: "AnswerID", measureName: "AvgResponseRate",
                                    dimensionValues: sortedCounts.map{$0.key},
                                    measureValues: sortedCounts.map{$0.value}))
        }
        return charts
    }

}

struct MyConfigurationKey: StorageKey {
    typealias Value = DataController
}

extension Application {
    var dataController: DataController? {
        get {
            self.storage[MyConfigurationKey.self]
        }
        set {
            self.storage[MyConfigurationKey.self] = newValue

        }
    }
}
