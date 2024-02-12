//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Иван on 12.02.2024.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
}
