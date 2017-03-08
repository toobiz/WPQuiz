//
//  Question.swift
//  WPQuiz
//
//  Created by Michał Tubis on 08.03.2017.
//  Copyright © 2017 Mike Tubis. All rights reserved.
//

import Foundation

class Question {
    
    var _text: String!
    var _imageUrl: String?
    var _quiz: Quiz!
    var _answers: [Answer]!
    
    var text: String {
        return _text
    }
    
    var imageUrl: String {
        return _imageUrl!
    }
    
    var quiz: Quiz {
        return _quiz
    }
    
    var answers: [Answer] {
        return _answers
    }
    
    // Initialize new Question
    
    init(dictionary: [String: AnyObject]) {
        
        if let text = dictionary["text"] as? String {
            self._text = text
        }
        
        if let imageUrl = dictionary["imageUrl"] as? String {
            self._imageUrl = imageUrl
        }
        
        if let quiz = dictionary["quiz"] as? Quiz {
            self._quiz = quiz
        }
        
        if let answers = dictionary["answers"] as? [Answer] {
            self._answers = answers
        }
        
    }
    
}
