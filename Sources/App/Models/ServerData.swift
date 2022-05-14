//
//  ServerData.swift
//  
//
//  Created by Shawn Long on 4/27/22.
//

import Foundation

/**
  An object which stores data collections used by the vapor server.
 */
class ServerData {
    private var surveys = [Survey]()
    private var surveyResponses = [SurveyResponse]()

    /// Stores the number of responses for every answer
    /// of every question of every survey. Keys are:
    /// SurveyID : QuestionID : AnswerID : responseCount
    private var answerCounts = [Int: [Int: [Int: Int]]]()

    /// Stores the number of non-null responses for every QuestionID
    /// SurveyID : QuestionID : responseCount
    private var nonNullResponseCounts = [Int: [Int: Int]]()

    private var queue = DispatchQueue(label: "ServerData.queue", attributes: .concurrent)

    /**
     Inserts a Survey into the `ServerData.surveys` array. If a survey with
     the existing id already exists, the existing survey is overwritten.

     - Parameter newSurvey: The new survey to be inserted
     - Complexity: O(*n*) where *n* is the size of the survey array
     */
    func storeSurvey(_ newSurvey: Survey) throws {
        queue.sync(flags: .barrier) {
            for (index, existingSurvey) in surveys.enumerated() where existingSurvey.id == newSurvey.id {
                surveys[index] = newSurvey
                return
            }
            surveys.append(newSurvey)
        }
    }

    /**
     Inserts a Survey into the `ServerData.surveyResponses` array. If a survey
     response with the existing id already exists, the existing survey is overwritten.

     - Parameter newResponse: The new survey response to be inserted
     - Complexity: O(*n*) where *n* is the size of the survey response array
     */
    func storeSurveyResponse(_ newResponse: SurveyResponse) throws -> Bool {
        queue.sync(flags: .barrier) {
            for (index, existingResponse) in surveyResponses.enumerated() where existingResponse.id == newResponse.id {
                surveyResponses[index] = newResponse
            }
            surveyResponses.append(newResponse)
        }
        return true
    }

    func writeSurveyResponses(_ responses: [SurveyResponse]) throws -> Bool {
        queue.sync(flags: .barrier) {
            self.surveyResponses += responses
            return true
        }

    }

    func writeSurveys(_ surveys: [Survey]) throws -> Bool {
        queue.sync(flags: .barrier) {
            self.surveys = surveys
            return true
        }

    }

        /**
         Searches the `ServerData.surveys` for the first survey for which
         the predicate is true.

         - Parameter predicate: A closure that takes an element of `ServerData.surveys` as its argument
         and returns a Boolean value indicating whether the element is a match.

         - Returns: The first element of `ServerData.surveys` that satisfies `predicate` or `nil` if
         there is no element that satisfies `predicate`.
         - Complexity: O(*n*) where *n* is the size of the survey array
         */
    func firstSurvey(where predicate: (Survey) throws -> Bool) rethrows -> Survey? {
        try queue.sync(flags: .barrier) {
            for survey in surveys {
                if try predicate(survey) { return survey }
            }
            return nil
        }
    }

    /**
     Searches the `ServerData.surveyResponses` for the first survey response for which
     the predicate is true.

     - Parameter predicate: A closure that takes an element of `ServerData.surveyResponses` as its argument
     and returns a Boolean value indicating whether the element is a match.

     - Returns: The first element of `ServerData.surveyResponses` that satisfies `predicate` or `nil` if
     there is no element that satisfies `predicate`.
     - Complexity: O(*n*) where *n* is the size of the survey response array
     */
    func firstSurveyResponse(where predicate: (SurveyResponse) throws -> Bool) rethrows -> SurveyResponse? {
        try queue.sync(flags: .barrier) {
            var returnResponse: SurveyResponse?
            for response in surveyResponses {
                if try predicate(response) {
                    returnResponse = response
                    break
                }
            }
            return returnResponse
        }
    }

    /**
     Returns an array containing, in order, the elements of `ServerData.surveys` that satisfy the given predicate.

     - Parameter isIncluded: A closure that takes an element of the survey array as its argument
     and returns a Boolean value indicating whether the element should be included in the returned array.
     - Returns: An array of the elements that `isIncluded` allowed.
     - Complexity: O(*n*) where *n* is the size of the survey array
     */
    func filterSurveys(_ isIncluded: (Survey) throws -> Bool) rethrows -> [Survey] {
        try queue.sync(flags: .barrier) {
            return try surveys.filter(isIncluded)
        }

    }

    /**
     Returns an array containing, in order, the elements of `ServerData.surveyResponses` that
     satisfy the given predicate.

     - Parameter isIncluded: A closure that takes an element of the survey response array as its argument
     and returns a Boolean value indicating whether the element should be included in the returned array.
     - Returns: An array of the elements that `isIncluded` allowed.
     - Complexity: O(*n*) where *n* is the size of the survey response array
     */
    func filterSurveyResponses(_ isIncluded: (SurveyResponse) throws -> Bool) rethrows -> [SurveyResponse] {
        try queue.sync(flags: .barrier) {
            return try surveyResponses.filter(isIncluded)
        }
    }

    func deleteSurveyResponse(id: UUID) -> Bool {
        queue.sync(flags: .barrier) {
            var mutableResponses = self.surveyResponses

            var indexToRemove: Int = -1
            for (index, response) in mutableResponses.enumerated() where response.id == id {
                indexToRemove = index
                break
            }
            if indexToRemove >= 0 {
                print("Attempting to remove")
                mutableResponses.remove(at: indexToRemove)
                self.surveyResponses = mutableResponses
                return true
            } else {
                return false
            }
        }
    }

    /// Increments the count of responses for the the specified, survey, question and answer
    func incrementResponseCount(surveyID: Int, questionID: Int, answerID: Int?) {
        queue.sync(flags: .barrier) {
            if let actualAnswerID: Int = answerID {
                self.answerCounts[surveyID]?[questionID]?[actualAnswerID]? += 1
                self.nonNullResponseCounts[surveyID]?[questionID]? += 1
            }
        }
    }

    func incrementResponseCounts(response: SurveyResponse) {
        queue.sync(flags: .barrier) {
            for questionID in 1...response.responses.count {
                guard let responseVal = response.responses[questionID] else {
                    print("Error: Missing question \(questionID) in response")
                    return
                }

                if let answerChoice: Int = responseVal {
                    self.answerCounts[response.surveyID]?[questionID]?[answerChoice]? += 1
                    self.nonNullResponseCounts[response.surveyID]?[questionID]? += 1
                }
            }
        }
    }
    func decrementResponseCounts(response: SurveyResponse) {
        queue.sync(flags: .barrier) {
            for questionID in 1...response.responses.count {
                guard let responseVal = response.responses[questionID] else {
                    print("Error: Missing question \(questionID) in response")
                    return
                }
                if let answerChoice = responseVal {
                    self.answerCounts[response.surveyID]?[questionID]?[answerChoice]? -= 1
                    self.nonNullResponseCounts[response.surveyID]?[questionID]? -= 1
                }
            }
        }

    }

    func getAnswerCount(surveyID: Int, questionID: Int, answerID: Int) -> Int {
        queue.sync(flags: .barrier) {
            return self.answerCounts[surveyID]?[questionID]?[answerID] ?? 0
        }
    }

    func getResponseCount(surveyID: Int, questionID: Int) -> Int? {
        queue.sync(flags: .barrier) {
            return self.nonNullResponseCounts[surveyID]?[questionID] ?? nil
        }
    }

    /// Initialize counts of zero for all answers to all questions for all surveys
    func initializeResponceCounts() {
        queue.sync(flags: .barrier) {
            let surveyCnt = self.surveys.count
            for surveyID in 0..<surveyCnt {
                let questionCount = self.surveys[surveyID].questions.keys.count
                let answerCount = self.surveys[surveyID].answers.keys.count

                self.answerCounts[surveyID] = [Int: [Int: Int]]()
                self.nonNullResponseCounts[surveyID] = [Int: Int]()

                for questionID in 1...questionCount {
                    self.answerCounts[surveyID]?[questionID] = [Int: Int]()
                    self.nonNullResponseCounts[surveyID]?[questionID] = 0

                    for answerID in 1...answerCount {
                        self.answerCounts[surveyID]?[questionID]?[answerID] = 0
                    }
                }
            }
        }
    }

}
