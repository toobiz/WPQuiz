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
    
    lazy var sharedContext: NSManagedObjectContext =  {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    func fetchAllQuizzes() -> [Quiz] {
        
        // Create the Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Quiz")
//        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "gameTitle", ascending: true)]
        
        // Execute the Fetch Request
        do {
            return try sharedContext.fetch(fetchRequest) as! [Quiz]
        } catch  let error as NSError {
            print("Error in fetchAllQuizzes(): \(error)")
            return [Quiz]()
        }
    }
    
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
            
            let elements = self.fetchAllQuizzes()
            
            for item in items {
                
                var titleToAdd = String()
                var urlToAdd = String()
                var idToAdd = NSNumber()
                
                if let id = item["id"] as? NSNumber {
                    idToAdd = id
                }
                
                if let title = item["title"] as? String {
                    titleToAdd = title
                }
                
                if let photoDict = item["mainPhoto"] as? [String:Any] {
                    urlToAdd = photoDict["url"] as! String
                }
                
                let quizDict: [String : AnyObject] = [
                    "id" : idToAdd as AnyObject,
                    "title" : titleToAdd as AnyObject,
                    "url" : urlToAdd as AnyObject
                ]
                
//                if self.quizzes.count == 0 {
//                    let quizToAdd = Quiz(dictionary: quizDict, context: self.sharedContext)
//                    CoreDataStackManager.sharedInstance().saveContext()
//                    self.quizzes.append(quizToAdd)
//                } else {
                    for element in elements {
                        if Int(element.id) != Int(idToAdd)  {
                            print("Dodajemy quiz to bazy")
                            let quizToAdd = Quiz(dictionary: quizDict, context: self.sharedContext)
                            self.quizzes.append(quizToAdd)
                        }
                    }
//            }
            

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
                var answersToAdd = [Answer]()

                if let text = item["text"] as? String  {
                    questionTextToAdd = text
//                    print(text)
                }
                
                if let answers = item["answers"] as? [[String:Any]] {
                    
                    
                    for answer in answers {
                        
                        var answerTextToAdd = String()
                        var boolToAdd = Bool()
                        
                        if let text = answer["text"] as? String {
                            answerTextToAdd = text
//                            print(text)
                        }
                        
                        if let bool = answer["isCorrect"] as? Bool {
                            boolToAdd = bool
//                            print(bool)
                        }
                        
                        let answerDict: [String : AnyObject] = [
                            "text" : answerTextToAdd as AnyObject,
                            "isCorrect" : boolToAdd as AnyObject,
                            ]
                        
                        let answerToAdd = Answer(dictionary: answerDict)
                        answersToAdd.append(answerToAdd)
                    }
                    
                }
                
                let questionDict: [String : AnyObject] = [
                    "text" : questionTextToAdd as AnyObject,
                    "quiz" : quiz,
                    "answers" : answersToAdd as AnyObject
                    ]
                
                let questionToAdd = Question(dictionary: questionDict)
                questions.append(questionToAdd)
            }
            
            completionHandler(true, questions, nil)
            
        }
        task.resume()
    }
}
