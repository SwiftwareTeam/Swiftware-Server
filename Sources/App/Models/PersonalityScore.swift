//
//  PersonalityScore.swift
//  
//
//  Created by Shawn Long on 5/8/22.
//

import Foundation
import Vapor

struct PersonalityScore : Content {
    var surveyID: Int
    var userID: String
    var responseID: UUID   /// ID of related surveyResponse
    var categories : [String]/// eg. openness, agreeableness, etc.
    var scores : [Double]
    /*
    init(){
        self.surveyID = 0
        self.userID = 0
        self.responseID  = 0   /// ID of related surveyResponse
        self.categories = ["Openness","Conscientiousness","Extraversion","Agreeableness","Neuroticism"] /// eg. openness, agreeableness, etc.
        self.scores : [0.0, 0.0, 0.0, 0.0, 0.0]
        
    }
     */
   
}
