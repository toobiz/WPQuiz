//
//  Quiz.swift
//  WPQuiz
//
//  Created by Michał Tubis on 07.03.2017.
//  Copyright © 2017 Mike Tubis. All rights reserved.
//

import Foundation

class Quiz {
    
//    fileprivate var _key: String!
    fileprivate var _id: Double!
    fileprivate var _title: String!
    fileprivate var _url: String!
    
//    var key: String {
//        return _key
//    }
    
    var id: Double {
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
//        self._key = key
        
        if let id = dictionary["id"] as? Double {
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
