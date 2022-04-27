//
//  Survey.swift
//  
//
//  Created by Shawn Long on 4/23/22.
//

import Foundation
import Vapor

struct Question: Content, Equatable {
    var id: Int
    var shortWording: String
    var fullWording: String
}

struct Answer: Content, Equatable {
    var id: Int
    var label: String
    var value: Int
}

struct Survey: Content, Equatable {
    var id: Int
    var name: String
    var group: String
    var questions: [Int : Question] // QuestionID: Question
    var answers: [Int : Answer] // AnswerID: Answer
}
