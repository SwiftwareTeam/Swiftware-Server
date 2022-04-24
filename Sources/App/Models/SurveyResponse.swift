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
    var responseType: String
    var questions: [String]
    var answers: [String]
}
