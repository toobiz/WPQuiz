//
//  Question.swift
//  WPQuiz
//
//  Created by Michał Tubis on 08.03.2017.
//  Copyright © 2017 Mike Tubis. All rights reserved.
//

import Foundation

class Question {
    
    fileprivate var _text: String!
    fileprivate var _imageUrl: String?
    fileprivate var _quiz: Quiz!
    
    var text: String {
        return _text
    }
    
    var imageUrl: String {
        return _imageUrl!
    }
    
    var quiz: Quiz {
        return _quiz
    }
    
    // Initialize new Quiz
    
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
        
    }
    
}
