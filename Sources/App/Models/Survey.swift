//
//  Survey.swift
//  
//
//  Created by Shawn Long on 4/23/22.
//

import Foundation
import Vapor

struct Question: Content {
    var id: String
    var shortWording: String
    var fullWording: String
}

struct Answer: Content {
    var id: String
    var label: String
    var value: Int
}

struct Survey: Content {
    var name: String
    var group: String
    var questions: [String : Question] // QuestionID: Question
    var answers: [String : Answer] // AnswerID: Answer
}
