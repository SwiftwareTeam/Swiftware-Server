//
//  SurveyResponse.swift
//  
//
//  Created by Shawn Long on 4/23/22.
//

import Foundation
import Vapor

struct SurveyResponse: Content {
    var id = UUID()
    var uid: String
    var surveyID: String
    var responseType: String
    var responses: [String : String] // QuestionID: AnswerID (Must be looked up from Survey Object)
}
