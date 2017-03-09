//
//  Quiz.swift
//  WPQuiz
//
//  Created by Michał Tubis on 07.03.2017.
//  Copyright © 2017 Mike Tubis. All rights reserved.
//

import Foundation
//import CoreData

class Quiz {
    
    var _id: Int!
    var _title: String!
    var _url: String!
//    var _questions: [Question]?
    var _progress: Int?
    var _score: Int?
    
    var id: Int {
        return _id
    }
    
    var title: String {
        return _title
    }
    
    var url: String {
        return _url
    }
    
//    var questions: [Question] {
//        return _questions!
//    }
    
    var progress: Int {
        return _progress!
    }
    
    var score: Int {
        return _score!
    }
    
    // Initialize new Quiz
    init(dictionary: [String: AnyObject]) {

//    init(dictionary: [String: AnyObject], context: NSManagedObjectContext) {
//        let entity =  NSEntityDescription.entity(forEntityName: "Quiz", in: context)!
//        super.init(entity: entity, insertInto: context)
        
        if let id = dictionary["id"] as? Int {
            self._id = id
        }
        
        if let title = dictionary["title"] as? String {
            self._title = title
        }
        
        if let url = dictionary["url"] as? String {
            self._url = url
        }
        
//        if let questions = dictionary["questions"] as? [Question] {
//            self._questions = questions
//        }
        
        if let progress = dictionary["progress"] as? Int {
            self._progress = progress
        }
        
        if let score = dictionary["score"] as? Int {
            self._score = score
        }
    }
    
}
