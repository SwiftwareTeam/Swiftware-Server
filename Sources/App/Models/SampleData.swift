//
//  SampleData.swift
//  
//
//  Created by Shawn Long on 4/27/22.
//

import Foundation

/**
 Simple struct storing sample objects for use in tests
 */
struct SampleData {
    var survey: Survey
    var surveys: [Survey]
    var response: SurveyResponse
    var responses: [SurveyResponse]

    init() {
        // Create Questions
        let question1 = Question(id: 1, shortWording: "Test", fullWording: "Very long test")
        let question2 = Question(id: 2, shortWording: "Test2", fullWording: "Very long test2")

        // Create Answers
        let answer1 = Answer(id: 1, label: "yes", value: 2)
        let answer2 = Answer(id: 2, label: "no", value: 1)
        let answer3 = Answer(id: 3, label: "Not Much", value: 1)
        let answer4 = Answer(id: 4, label: "A little", value: 2)
        let answer5 = Answer(id: 5, label: "A lot", value: 3)

        // Create Surveys
        let survey1 = Survey(id: 1, name: "Test Survey", group: "Test Group",
                             questions: [1: question1],
                             answers: [1: answer1, 2: answer2])

        let survey2 = Survey(id: 2, name: "A different Test Survey", group: "Test Group",
                             questions: [1: question1, 2: question2],
                             answers: [1: answer1, 2: answer2, 3: answer3, 4: answer4, 5: answer5])

        // Create Responses
        let response1 = SurveyResponse(uid: "Shawn",
                                       surveyID: 1,
                                       responseType: "pre",
                                       responses: [1: nil, 2: nil, 3: nil,
                                                   4: nil, 5: nil, 6: nil,
                                                   7: nil, 8: nil, 9: nil,
                                                   10: nil, 11: nil, 12: nil,
                                                   13: nil, 14: nil, 15: nil,
                                                   16: nil, 17: nil, 18: nil,
                                                   19: nil, 20: nil, 21: nil,
                                                   22: nil, 23: nil, 24: nil,
                                                   25: nil, 26: nil, 27: nil,
                                                   28: nil, 29: nil, 30: nil,
                                                   31: nil, 32: nil, 33: nil,
                                                   34: nil, 35: nil, 36: nil,
                                                   37: nil, 38: nil, 39: nil,
                                                   40: nil, 41: nil, 42: nil,
                                                   43: nil, 44: nil])
        let response2 = SurveyResponse(uid: "Shawn",
                                       surveyID: 1,
                                       responseType: "pre",
                                       responses: [1: 2, 2: nil, 3: nil,
                                                   4: nil, 5: nil, 6: nil,
                                                   7: nil, 8: nil, 9: nil,
                                                   10: nil, 11: nil, 12: nil,
                                                   13: nil, 14: nil, 15: nil,
                                                   16: nil, 17: nil, 18: nil,
                                                   19: nil, 20: nil, 21: nil,
                                                   22: nil, 23: nil, 24: nil,
                                                   25: nil, 26: nil, 27: nil,
                                                   28: nil, 29: nil, 30: nil,
                                                   31: nil, 32: nil, 33: nil,
                                                   34: nil, 35: nil, 36: nil,
                                                   37: nil, 38: nil, 39: nil,
                                                   40: nil, 41: nil, 42: nil,
                                                   43: nil, 44: nil])
        let response3 = SurveyResponse(uid: "Arzhang",
                                       surveyID: 2,
                                       responseType: "new",
                                       responses: [1: 1, 2: 5, 3: nil,
                                                   4: nil, 5: nil, 6: nil,
                                                   7: nil, 8: nil, 9: nil,
                                                   10: nil, 11: nil, 12: nil,
                                                   13: nil, 14: nil, 15: nil,
                                                   16: nil, 17: nil, 18: nil,
                                                   19: nil, 20: nil, 21: nil,
                                                   22: nil, 23: nil, 24: nil,
                                                   25: nil, 26: nil, 27: nil,
                                                   28: nil, 29: nil, 30: nil,
                                                   31: nil, 32: nil, 33: nil,
                                                   34: nil, 35: nil, 36: nil,
                                                   37: nil, 38: nil, 39: nil,
                                                   40: nil, 41: nil, 42: nil,
                                                   43: nil, 44: nil])
        let response4 = SurveyResponse(uid: "Anushka",
                                       surveyID: 1,
                                       responseType: "new",
                                       responses: [1: 1, 2: nil, 3: nil,
                                                   4: nil, 5: nil, 6: nil,
                                                   7: nil, 8: nil, 9: nil,
                                                   10: nil, 11: nil, 12: nil,
                                                   13: nil, 14: nil, 15: nil,
                                                   16: nil, 17: nil, 18: nil,
                                                   19: nil, 20: nil, 21: nil,
                                                   22: nil, 23: nil, 24: nil,
                                                   25: nil, 26: nil, 27: nil,
                                                   28: nil, 29: nil, 30: nil,
                                                   31: nil, 32: nil, 33: nil,
                                                   34: nil, 35: nil, 36: nil,
                                                   37: nil, 38: nil, 39: nil,
                                                   40: nil, 41: nil, 42: nil,
                                                   43: nil, 44: nil])
        let response5 = SurveyResponse(uid: "Adrian",
                                       surveyID: 2,
                                       responseType: "pre",
                                       responses: [1: nil, 2: nil, 3: nil,
                                                   4: nil, 5: nil, 6: nil,
                                                   7: nil, 8: nil, 9: nil,
                                                   10: nil, 11: nil, 12: nil,
                                                   13: nil, 14: nil, 15: nil,
                                                   16: nil, 17: nil, 18: nil,
                                                   19: nil, 20: nil, 21: nil,
                                                   22: nil, 23: nil, 24: nil,
                                                   25: nil, 26: nil, 27: nil,
                                                   28: nil, 29: nil, 30: nil,
                                                   31: nil, 32: nil, 33: nil,
                                                   34: nil, 35: nil, 36: nil,
                                                   37: nil, 38: nil, 39: nil,
                                                   40: nil, 41: nil, 42: nil,
                                                   43: nil, 44: nil])
        let response6 = SurveyResponse(uid: "So",
                                       surveyID: 2,
                                       responseType: "post",
                                       responses: [1: 2, 2: 1, 3: nil,
                                                   4: nil, 5: nil, 6: nil,
                                                   7: nil, 8: nil, 9: nil,
                                                   10: nil, 11: nil, 12: nil,
                                                   13: nil, 14: nil, 15: nil,
                                                   16: nil, 17: nil, 18: nil,
                                                   19: nil, 20: nil, 21: nil,
                                                   22: nil, 23: nil, 24: nil,
                                                   25: nil, 26: nil, 27: nil,
                                                   28: nil, 29: nil, 30: nil,
                                                   31: nil, 32: nil, 33: nil,
                                                   34: nil, 35: nil, 36: nil,
                                                   37: nil, 38: nil, 39: nil,
                                                   40: nil, 41: nil, 42: nil,
                                                   43: nil, 44: nil])

        // Initializes struct vars
        self.survey = survey1
        self.surveys = [survey1, survey2]
        self.response = response1
        self.responses = [response1, response2, response3, response4, response5, response6]
    }
}
