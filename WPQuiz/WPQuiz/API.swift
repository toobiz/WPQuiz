//
//  API.swift
//  WPQuiz
//
//  Created by Michał Tubis on 06.03.2017.
//  Copyright © 2017 Mike Tubis. All rights reserved.
//

import UIKit
import CoreData

class API: NSObject {
    
    typealias CompletionHander = (_ result: AnyObject?, _ error: NSError?) -> Void
    
    var session: URLSession
    var quizzes = [Quiz]()

    override init() {
        session = URLSession.shared
        super.init()
    }
    
    // MARK: - Shared Instance
    
    class func sharedInstance() -> API {
        struct Singleton {
            static var sharedInstance = API()
        }
        return Singleton.sharedInstance
    }
    
    // MARK: - Core Data
    
    lazy var sharedContext: NSManagedObjectContext =  {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    func fetchAllQuizzes() -> [Quiz] {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Quiz")
        
        do {
            return try sharedContext.fetch(fetchRequest) as! [Quiz]
        } catch  let error as NSError {
            print("Error in fetchAllQuizzes(): \(error)")
            return [Quiz]()
        }
    }
    
    // MARK: - WP API
    
    func downloadListOfQuizzes(completionHandler: @escaping (_ success: Bool, _ quizzes: [Quiz], _ errorString: String?) -> Void) {
        
        let urlString = API.Constants.LIST_URL
        let request = NSMutableURLRequest(url: NSURL(string: urlString)! as URL)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            guard (error == nil) else {
                print("Connection Error")
                return
            }
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            let parsedResponse = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
            
            guard let items = parsedResponse["items"] as? [[String:Any]] else {
                print("Cannot find keys 'items' in parsedResponse")
                return
            }
            
            self.quizzes = self.fetchAllQuizzes()
            var ids = [NSNumber]()
            
            for quiz in self.quizzes {
                ids.append(quiz.id)
            }
            
            for item in items {
                
                var idToAdd = NSNumber()
                
                if let id = item["id"] as? NSNumber {
                    idToAdd = id
                }
                
                if ids.contains(idToAdd) {
                    print("Already in Core Data")
                } else {
                    print("Adding quiz to Core Data")
                    
                    var titleToAdd = String()
                    var urlToAdd = String()
                    
                    if let title = item["title"] as? String {
                        titleToAdd = title
                    }
                    
                    if let photoDict = item["mainPhoto"] as? [String:Any] {
                        urlToAdd = photoDict["url"] as! String
                    }
                    
                    let quizDict: [String : AnyObject] = [
                        "id" : idToAdd as AnyObject,
                        "title" : titleToAdd as AnyObject,
                        "urlString" : urlToAdd as AnyObject
                    ]
                    
                    let quizToAdd = Quiz(dictionary: quizDict, context: self.sharedContext)
                    CoreDataStackManager.sharedInstance().saveContext()
                    self.quizzes.append(quizToAdd)
                }

            }
            CoreDataStackManager.sharedInstance().saveContext()
            completionHandler(true, self.quizzes, nil)
            
        }
        task.resume()
    }
    
    func downloadQuiz(quiz: Quiz, completionHandler: @escaping (_ success: Bool, _ questions: [Question], _ errorString: String?) -> Void) {
        let urlString = API.Constants.QUIZ_URL + "\(quiz.id)" + "/0"
        let request = NSMutableURLRequest(url: NSURL(string: urlString)! as URL)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            guard (error == nil) else {
                print("Connection Error")
                return
            }
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            let parsedResponse = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
            
            guard let items = parsedResponse["questions"] as? [[String:Any]] else {
                print("Cannot find keys 'questions' in parsedResponse")
                return
            }
            
            var questions = [Question]()
            
            for item in items {
                
                var questionTextToAdd = String()
                var questionImageUrlToAdd = String()
                var answersToAdd = [Answer]()

                if let text = item["text"] as? String  {
                    questionTextToAdd = text
                }
                
                if let answers = item["answers"] as? [[String:Any]] {
                    
                    for answer in answers {
                        
                        var answerTextToAdd = String()
                        var boolToAdd = Bool()
                        
                        if let text = answer["text"] as? String {
                            answerTextToAdd = text
                        }
                        else if let text = answer["text"] as? Int {
                            answerTextToAdd = String(text)
                        }
                        
                        if let bool = answer["isCorrect"] as? Bool {
                            boolToAdd = bool
                        }
                        
                        let answerDict: [String : AnyObject] = [
                            "text" : answerTextToAdd as AnyObject,
                            "isCorrect" : boolToAdd as AnyObject,
                            ]
                        
                        let answerToAdd = Answer(dictionary: answerDict)
                        answersToAdd.append(answerToAdd)
                    }
                }
                
                if let image = item["image"] as? [String: Any] {
                            questionImageUrlToAdd = image["url"] as! String
                }
                
                let questionDict: [String : AnyObject] = [
                    "text" : questionTextToAdd as AnyObject,
                    "quiz" : quiz,
                    "answers" : answersToAdd as AnyObject,
                    "imageUrl" : questionImageUrlToAdd as AnyObject
                    ]
                
                let questionToAdd = Question(dictionary: questionDict)
                questions.append(questionToAdd)
            }
            
            completionHandler(true, questions, nil)
        }
        task.resume()
    }
    
    func downloadImage(urlString: String, completionHandler: @escaping (_ success: Bool, _ image: UIImage, _ errorString: String?) -> Void) {
        
        let request = NSMutableURLRequest(url: NSURL(string: urlString)! as URL)
        let image = UIImage()

        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            if response != nil {
                let image = UIImage(data: data!)
                
//                let hasAlpha = true
//                let scale: CGFloat = 3.5
//                let sizeChange = CGSize(width: 192, height: 108)
//                
//                UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
//                image?.draw(in: CGRect(origin: CGPoint.zero, size: sizeChange))
                
//                let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
                
                completionHandler(true, image!, nil)
            }
            if let error = error {
                completionHandler(false, image, error.localizedDescription)
            }

        }
        task.resume()
    }
    
}
