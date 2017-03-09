//
//  Quiz.swift
//  WPQuiz
//
//  Created by Michał Tubis on 07.03.2017.
//  Copyright © 2017 Mike Tubis. All rights reserved.
//

import Foundation
import CoreData

@objc (Quiz)
class Quiz: NSManagedObject {
    
//    struct Keys {
//        static let id = "id"
//        static let title = "title"
//        static let url = "url"
//        static let progress = "progress"
//        static let score = "score"
//    }
    
    @NSManaged var id: NSNumber
    @NSManaged var title: String
    @NSManaged var url: String
    @NSManaged var progress: NSNumber
    @NSManaged var score: NSNumber
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    init(dictionary: [String: AnyObject], context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entity(forEntityName: "Quiz", in: context)!
        super.init(entity: entity, insertInto: context)
        
        if let quiz_id = dictionary["id"] {
            id = quiz_id as! NSNumber
        }
        
        if let quiz_title = dictionary["title"] {
            title = quiz_title as! String
        }
        
        if let quiz_url = dictionary["url"] {
            url = quiz_url as! String
        }
        
        if let quiz_progress = dictionary["progress"] {
            progress = quiz_progress as! NSNumber
        }
        
        if let quiz_score = dictionary["score"] {
            score = quiz_score as! NSNumber
        }
    }
    
}
