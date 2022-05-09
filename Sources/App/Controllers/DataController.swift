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

    func getSurveyResponses(uid: String) throws -> [SurveyResponse] {
        return data.filterSurveyResponses({$0.uid == uid})
    }

    func getSurveyResponse(id: UUID) throws -> SurveyResponse? {
        return data.firstSurveyResponse(where: {$0.id == id})
    }

    func getSurveys() throws -> [Survey] {
        return data.filterSurveys({_ in true})
    }

    func getUsers() throws -> [String] {
        return Array(Set(data.filterSurveyResponses({_ in true}).map{ $0.uid })).sorted()
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

    func responseExists(forUser uid: String) throws -> Bool {
        return data.firstSurveyResponse(where: { $0.uid == uid } ) != nil
    }

    /// This is a helper function used to reverse an Answer Choice for Personality Test Analysis.
    /// For example, on a scale of 1 to 5, 1 becomes 5, 2 becomes 4, and so on.
    func reverse(_ score: Int, maxScore: Int = 5) -> Int {
        return maxScore - score + 1
    }

    // TODO: Implement Function (Remove placeholder return statement)
    func personalityScore(forUser uid: String) throws -> PersonalityScore? {

        /// Mark: - Retrieve Response for Personality Test Calculation
        guard let responses = try? self.getSurveyResponses(uid: uid) else { return nil }
        var responseForCalculation: SurveyResponse
        let postResponses = responses.filter { $0.responseType == "post" }

        /// Ideally select the first response of type post, otherwise, just select the first response
        if postResponses.count > 0 {
            responseForCalculation = postResponses[0]
        } else {
            responseForCalculation = responses[0]
        }

        /// Mark: - Unpack Answers for Response
        let answers = responseForCalculation.responses.values

        /// Formulas for analyzing the big five test use indexing at 1 instead of 0, so
        /// a dummy value in inserted at index 0 for clarity
        var unpackedAnswers = [0]

        /// Unpack the optionals from answers into new array
        for answer in answers {
            if let unpackedAnswer: Int = answer {
                unpackedAnswers.append(unpackedAnswer)
            } else {
                unpackedAnswers.append(3) /// Append the median value of 3
            }
        }

        /// Mark: - Calculate the Response
        ///
        /// R after question means the answer should be reversed
        /// All values for each category are added together, then divided by 40

        /// Extraversion : 1, 6R, 11, 16, 21R, 26, 31R, 36
        let extraversion = unpackedAnswers[1] + reverse(unpackedAnswers[6])
          + unpackedAnswers[11] + unpackedAnswers[16]
          + reverse(unpackedAnswers[21]) + unpackedAnswers[26]
          + reverse(unpackedAnswers[31]) + unpackedAnswers[36]

        /// Agreeableness: 2R, 7, 12R, 17, 22, 27R, 32, 37R, 42
        let agreeableness = reverse(unpackedAnswers[2]) + unpackedAnswers[7]
          + reverse(unpackedAnswers[12]) + unpackedAnswers[17]
          + unpackedAnswers[22] + reverse(unpackedAnswers[27])
          + unpackedAnswers[32] + reverse(unpackedAnswers[37])
          + unpackedAnswers[42]

        /// Conscientiousness: 3, 8R, 13, 18R, 23R, 28, 33, 38, 43R
        let conscientiousness = unpackedAnswers[3] + reverse(unpackedAnswers[8])
          + unpackedAnswers[13] + reverse(unpackedAnswers[18])
          + reverse(unpackedAnswers[23]) + unpackedAnswers[28]
          + unpackedAnswers[33] + unpackedAnswers[38]
          + reverse(unpackedAnswers[43])

        /// Neuroticism: 4, 9R, 14, 19, 24R, 29, 34R, 39
        let neuroticism = unpackedAnswers[4] + reverse(unpackedAnswers[9])
          + unpackedAnswers[14] + unpackedAnswers[19]
          + reverse(unpackedAnswers[24]) + unpackedAnswers[29]
          + reverse(unpackedAnswers[34]) + unpackedAnswers[39]


        /// Openness: 5, 10, 15, 20, 25, 30, 35R, 40, 41R, 44
        let openness = unpackedAnswers[5] + unpackedAnswers[10]
          + unpackedAnswers[15] + unpackedAnswers[20]
          + unpackedAnswers[25] + unpackedAnswers[30]
          + reverse(unpackedAnswers[35]) + unpackedAnswers[40]
          + reverse(unpackedAnswers[41]) + unpackedAnswers[44]

        return PersonalityScore(surveyID: 1,
                                userID: uid,
                                responseID: responseForCalculation.id,
                                categories: ["Extraversion",
                                             "Agreeableness",
                                             "Conscientiousness",
                                             "Neuroticism",
                                             "Openness",],
                                scores: [Double(extraversion) / 40.0,
                                         Double(agreeableness) / 40.0,
                                         Double(conscientiousness) / 40.0,
                                         Double(neuroticism) / 40.0,
                                         Double(openness) / 40.0])

//        /// Temporary placeholder
//        return PersonalityScore(surveyID: 1,
//                                userID: "u00",
//                                responseID: UUID(),
//                                categories: ["Openness",
//                                             "Conscientiousness",
//                                             "Extraversion",
//                                             "Agreeableness",
//                                             "Neuroticism",],
//                                scores: [0.73, 0.40, 0.46, 0.85, 0.40])
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
