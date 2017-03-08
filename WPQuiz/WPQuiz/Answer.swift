//
//  Answer.swift
//  WPQuiz
//
//  Created by Michał Tubis on 08.03.2017.
//  Copyright © 2017 Mike Tubis. All rights reserved.
//

import Foundation

class Answer {
    
    var _text: String!
    var _isCorrect: Bool!
    var _question: Question!
    
    var text: String {
        return _text
    }
    
    var isCorrect: Bool {
        return _isCorrect
    }
    
    var question: Question {
        return _question
    }
    
    // Initialize new Answer
    
    init(dictionary: [String: AnyObject]) {
        
        if let text = dictionary["text"] as? String {
            self._text = text
        }
        
        if let isCorrect = dictionary["isCorrect"] as? Bool {
            self._isCorrect = isCorrect
        }
        
        if let questions = dictionary["question"] as? Question {
            self._question = question
        }
        
    }
    
}
