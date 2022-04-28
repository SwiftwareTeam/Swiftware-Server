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

        let survey2 = Survey(id:2, name: "A different Test Survey", group: "Test Group",
                             questions: [1: question1, 2: question2],
                             answers: [1: answer1, 2: answer2, 3: answer3, 4: answer4, 5: answer5])

        // Create Responses
        let response1 = SurveyResponse(uid: "Shawn", surveyID: 1, responseType: "pre", responses: [1: nil])
        let response2 = SurveyResponse(uid: "Shawn", surveyID: 1, responseType: "pre", responses: [1: 2])
        let response3 = SurveyResponse(uid: "Arzhang", surveyID: 2, responseType: "new", responses: [1: 1, 2: 5])
        let response4 = SurveyResponse(uid: "Anushka", surveyID: 1, responseType: "new", responses: [1: 1])
        let response5 = SurveyResponse(uid: "Adrian", surveyID: 2, responseType: "pre", responses: [1: nil, 2: nil])
        let response6 = SurveyResponse(uid: "So", surveyID: 2, responseType: "post", responses: [1: 2, 2: 1])

        // Initializes struct vars
        self.survey = survey1
        self.surveys = [survey1, survey2]
        self.response = response1
        self.responses = [response1, response2, response3, response4, response5, response6]
    }
}
