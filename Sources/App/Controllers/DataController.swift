//
//  ServerData.swift
//  
//
//  Created by Shawn Long on 4/17/22.
//

import Vapor
import Foundation

enum DataControllerError: Error {
    case fileError(message: String)
    case storageError(message: String)
}

class DataController {

    private let data = ServerData()
    private let fileController: FileController
    private let app: Application

    init(_ app: Application) {
        self.app = app
        self.fileController = FileController(app)

        do {
            let surveys = [
                try fileController.loadSurvey(id: 1, name: "Big Five", group: "I see myself as"),
                try fileController.loadSurvey(id: 2, name: "Flourishing Scale", group: "Flourishing Scale"),
                try fileController.loadSurvey(id: 3, name: "Loneliness Scale", group: "Loneliness Scale"),
                try fileController.loadSurvey(id: 4, name: "Positive and Negative Affect Schedule", group: "PANAS"),
                try fileController.loadSurvey(id: 5,
                                              name: "Perceived Stress Scale",
                                              group: "In the last month how often have you been"),
                try fileController.loadSurvey(id: 6, name: "Patient Health Questionnaire-9", group: "PHQ-9")
            ]

            for surveyID in 1...surveys.count {
                try data.storeSurvey(surveys[surveyID - 1])
                let responses = try fileController.loadResponses(surveyID: surveyID)
                _ = try data.writeSurveyResponses(responses)
            }

            _ = try backup()
            calculateAllResponseRates() /// Calculate after loading data
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
        return data.filterSurveys({ _ in true})
    }

    func getUsers() throws -> [String] {
        return Array(Set(data.filterSurveyResponses({ _ in true}).map { $0.uid })).sorted()
    }

    func createResponse(response: SurveyResponse) throws -> Bool {
        guard isValidResponse(response) else {
            app.logger.error("Response is not valid")
            return false
        }

        if let stored_resp = data.firstSurveyResponse(where: { $0.id == response.id }) {
            data.decrementResponseCounts(response: stored_resp)
        }
        data.incrementResponseCounts(response: response)

        return try data.storeSurveyResponse(response)
    }

    func updateResponse(response: SurveyResponse) throws -> Bool {
        guard isValidResponse(response) else {
            app.logger.error("Response is not valid")
            return false
        }

        if let stored_resp = data.firstSurveyResponse(where: { $0.id == response.id }) {
            data.decrementResponseCounts(response: stored_resp)
        }

        data.incrementResponseCounts(response: response)

        return try data.storeSurveyResponse(response)
    }

    func deleteResponse(id: UUID) throws -> Bool {
        if let stored_resp = data.firstSurveyResponse(where: { $0.id == id }) {
            data.decrementResponseCounts(response: stored_resp)
        }

        app.logger.critical("Data Controller: Atetmpting to delete")
        return data.deleteSurveyResponse(id: id)
    }

    /// Checks whehter a response for the given user exists inside the
    /// ServerData object. Used while updating or inserting new
    /// responses
    func responseExists(forUser uid: String) throws -> Bool {
        return data.firstSurveyResponse(where: { $0.uid == uid }) != nil
    }

    /// Checks whether the response contains a valid Survey, and that
    /// it contains a key for every questionID in that survey
    ///
    /// - Returns true if survey exists and questionIDs in survey
    /// match the survey itself.
    func isValidResponse(_ response: SurveyResponse) -> Bool {
        let questionIDs = response.responses.keys.sorted(by: <)

        guard let survey = data.firstSurvey(where: { $0.id == response.surveyID }) else {
            app.logger.error("Survey \(response.surveyID) not found")
            return false
        }

        let actualQuestionIDs = survey.questions.keys.sorted(by: <)

        return questionIDs == actualQuestionIDs
    }

    /// This is a helper function used to reverse an Answer Choice for Personality Test Analysis.
    /// For example, on a scale of 1 to 5, 1 becomes 5, 2 becomes 4, and so on.
    func reverse(_ score: Int, maxScore: Int = 5) -> Int {
        return maxScore - score + 1
    }

    func personalityScore(forUser uid: String) throws -> PersonalityScore? {
        guard let responses = try? self.getSurveyResponses(uid: uid) else { return nil }
        var responseForCalculation: SurveyResponse
        let postResponses = responses.filter { $0.responseType == "post" }

        /// Ideally select the first response of type post, otherwise, just select the first response
        if postResponses.count > 0 {
            responseForCalculation = postResponses[0]
        } else {
            responseForCalculation = responses[0]
        }
        
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

        let scores = calculateScores(unpackedAnswers)

        return PersonalityScore(surveyID: 1,
                                userID: uid,
                                responseID: responseForCalculation.id,
                                categories: ["Extraversion",
                                             "Agreeableness",
                                             "Conscientiousness",
                                             "Neuroticism",
                                             "Openness"],
                                scores: scores)
    }

    /// Calculate Big Five Personality Scores based on answer array
    ///
    /// R after question means the answer should be reversed
    /// All values for each category are added together, then divided by 40
    func calculateScores(_ answers: [Int]) -> [Double] {

        /// Extraversion : 1, 6R, 11, 16, 21R, 26, 31R, 36
        let extraversion = answers[1] + reverse(answers[6])
          + answers[11] + answers[16]
          + reverse(answers[21]) + answers[26]
          + reverse(answers[31]) + answers[36]

        /// Agreeableness: 2R, 7, 12R, 17, 22, 27R, 32, 37R, 42
        let agreeableness = reverse(answers[2]) + answers[7]
          + reverse(answers[12]) + answers[17]
          + answers[22] + reverse(answers[27])
          + answers[32] + reverse(answers[37])
          + answers[42]

        /// Conscientiousness: 3, 8R, 13, 18R, 23R, 28, 33, 38, 43R
        let conscientiousness = answers[3] + reverse(answers[8])
          + answers[13] + reverse(answers[18])
          + reverse(answers[23]) + answers[28]
          + answers[33] + answers[38]
          + reverse(answers[43])

        /// Neuroticism: 4, 9R, 14, 19, 24R, 29, 34R, 39
        let neuroticism = answers[4] + reverse(answers[9])
          + answers[14] + answers[19]
          + reverse(answers[24]) + answers[29]
          + reverse(answers[34]) + answers[39]

        /// Openness: 5, 10, 15, 20, 25, 30, 35R, 40, 41R, 44
        let openness = answers[5] + answers[10]
          + answers[15] + answers[20]
          + answers[25] + answers[30]
          + reverse(answers[35]) + answers[40]
          + reverse(answers[41]) + answers[44]

        return [Double(extraversion) / 40.0,
                 Double(agreeableness) / 40.0,
                 Double(conscientiousness) / 40.0,
                 Double(neuroticism) / 40.0,
                 Double(openness) / 40.0]
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
                    calculateAllResponseRates()
                    return responseSuccess && surveySuccess
                }
            }
        }
        return false
    }

    func deprecatedAvgResponseRate(surveyID: Int) -> [ChartData]? {
        app.logger.warning("This function for AvgResponse Rate is deprecated")
        let responses = data.filterSurveyResponses { $0.surveyID == surveyID && $0.responseType == "post" }
        guard let survey = data.firstSurvey(where: {$0.id == surveyID}) else { return nil }
        let questionCount = survey.questions.count
        let answerCount = survey.answers.count

        var counts = Dictionary(uniqueKeysWithValues: survey.answers.map { ($0.key, 0.0)})
        var charts = [ChartData]()

        for questionID in 1 ... questionCount {
            counts = Dictionary(uniqueKeysWithValues: survey.answers.map { ($0.key, 0.0) })
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
                                    dimensionValues: sortedCounts.map { $0.key },
                                    measureValues: sortedCounts.map { $0.value }))
        }
        return charts
    }

    /// This calculates the response rates for all surveys by iterating
    /// over surveyResponses one at a time.
    ///
    /// - Complexity: O(*n*) where *n* is the size of the surveyResponse array
    func calculateAllResponseRates() {

        data.initializeResponceCounts()

        let responses = data.filterSurveyResponses { $0.responseType == "post" }
        let surveys = data.filterSurveys { _ in true }

        for survey in surveys {
            let questionCount = survey.questions.count

            for questionID in 1...questionCount {
                for response in responses.filter({ $0.surveyID == survey.id }) {
                    if let answerChoice = response.responses[questionID] {
                        data.incrementResponseCount(surveyID: survey.id, questionID: questionID, answerID: answerChoice)
                    }
                }
            }

        }
    }

    /// Return Avg Response Rates based on Cached Values
    func AvgResponseRates(surveyID: Int) -> [ChartData]? {
        guard let survey = data.firstSurvey(where: {$0.id == surveyID}) else { return nil }
        let questionCount = survey.questions.count
        let answerCount = survey.answers.count

        var charts = [ChartData]()

        for questionID in 1...questionCount {
            var answerCounts = [Int: Int]()
            for answerID in 1...answerCount {
                answerCounts[answerID] = data.getAnswerCount(surveyID: surveyID,
                                                             questionID: questionID,
                                                             answerID: answerID)
            }
            if let nonNullResponseCount = data.getResponseCount(surveyID: surveyID, questionID: questionID) {
                let sortedCounts = answerCounts.sorted(by: <)
                let dimmensionValues =  sortedCounts.map { $0.key }
                let measureValues = sortedCounts.map { 100.0 * Double($0.value) / Double(nonNullResponseCount) }
                charts.append(ChartData(surveyID: surveyID,
                                        questionID: questionID,
                                        dimensionName: "AnswerID",
                                        measureName: "AvgResponseRate",
                                        dimensionValues: dimmensionValues,
                                        measureValues: measureValues))
            }

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
