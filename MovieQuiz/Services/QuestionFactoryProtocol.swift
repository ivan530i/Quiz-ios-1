//
//  QuestionFactoryProtocol.swift
//  MovieQuiz
//
//  Created by Иван on 11.02.2024.
//

import Foundation

protocol QuestionFactoryProtocol {
    var delegate: QuestionFactoryDelegate? {get set}
    func requestNextQuestion()
}
