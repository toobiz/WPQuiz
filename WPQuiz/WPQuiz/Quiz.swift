//
//  Quiz.swift
//  WPQuiz
//
//  Created by Michał Tubis on 07.03.2017.
//  Copyright © 2017 Mike Tubis. All rights reserved.
//

import Foundation

class Quiz {
    
    fileprivate var _id: Int!
    fileprivate var _title: String!
    fileprivate var _url: String!
    
    var id: Int {
        return _id
    }
    
    var title: String {
        return _title
    }
    
    var url: String {
        return _url
    }
    
    // Initialize new Quiz
    
    init(dictionary: [String: AnyObject]) {
        
        if let id = dictionary["id"] as? Int {
            self._id = id
        }
        
        if let title = dictionary["title"] as? String {
            self._title = title
        }
        
        if let url = dictionary["url"] as? String {
            self._url = url
        }
        
    }
    
}
