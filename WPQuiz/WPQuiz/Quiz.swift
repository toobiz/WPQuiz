//
//  Quiz.swift
//  WPQuiz
//
//  Created by Michał Tubis on 07.03.2017.
//  Copyright © 2017 Mike Tubis. All rights reserved.
//

import Foundation
import CoreData
import UIKit

@objc (Quiz)
class Quiz: NSManagedObject {
    
    @NSManaged var id: NSNumber
    @NSManaged var title: String
    @NSManaged var progress: NSNumber?
    @NSManaged var score: NSNumber
    @NSManaged var questionsCount: NSNumber
    @NSManaged var currentPage: NSNumber
    @NSManaged var urlString: String?
    
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
        
        if let quiz_url = dictionary["urlString"] {
            urlString = quiz_url as? String
        }
        
        if let quiz_progress = dictionary["progress"] {
            progress = quiz_progress as? NSNumber
        }
        
        if let quiz_score = dictionary["score"] {
            score = quiz_score as! NSNumber
        }
        
        if let questions_count = dictionary["questionsCount"] {
            progress = questions_count as? NSNumber
        }
        
        if let current_page = dictionary["currentPage"] {
            score = current_page as! NSNumber
        }
    }
    
    var image: UIImage? {
        
        get {
            var imageString = String()
            if urlString != nil {
                imageString = urlString!
            }
            let url = URL(fileURLWithPath: imageString)
            let fileName = url.lastPathComponent
            return ImageCache.Caches.imageCache.imageWithIdentifier(fileName)
        }
        
        set {
            if urlString != nil {
                let imageString = urlString!
                let url = URL(fileURLWithPath: imageString)
                let fileName = url.lastPathComponent
                ImageCache.Caches.imageCache.storeImage(newValue, withIdentifier: fileName)
            }
            
        }
    }

}
