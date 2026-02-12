//
//  ChatDTO.swift
//  FMChatsServer
//
//  Created by Robert Goedman on 2/10/26.
//

import Foundation
import Vapor

/// Data transfer object for Chat entity
struct ChatDTO: Content {
    let id: UUID
    let title: String
    let timestamp: Date
    let questions: [QuestionDTO]?
}

/// Data transfer object for Question entity
struct QuestionDTO: Content {
    let id: UUID
    let questionText: String
    let answerText: String?
    let timestamp: Date
}
