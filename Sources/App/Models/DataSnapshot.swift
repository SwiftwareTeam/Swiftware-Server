//
//  File.swift
//  
//
//  Created by Shawn Long on 4/28/22.
//

import Foundation

struct DataSnapshot: Codable {
    var date = Date()
    var surveys: [Survey]
    var surveyResponses: [SurveyResponse]
}
