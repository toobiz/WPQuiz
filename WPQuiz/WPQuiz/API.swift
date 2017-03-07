//
//  API.swift
//  WPQuiz
//
//  Created by Michał Tubis on 06.03.2017.
//  Copyright © 2017 Mike Tubis. All rights reserved.
//

import UIKit

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
            let parsedResponse = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! AnyObject
            
            guard let items = parsedResponse["items"] as? [[String:Any]] else {
                print("Cannot find keys 'items' in parsedResponse")
                return
            }
            //            print(items)
            
//            var titles = [String]()
//            var urls = [String]()
            
            for item in items {
                
                var titleToAdd = String()
                var urlToAdd = String()
                var idToAdd = Int()
                
                if let id = item["id"] as? Int {
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
                
                let quizToAdd = Quiz(dictionary: quizDict as [String : AnyObject])
                self.quizzes.append(quizToAdd)
            }
            
            completionHandler(true, self.quizzes, nil)
            
        }
        task.resume()
    }
    
    func downloadQuiz(id: String, completionHandler: @escaping (_ success: Bool, _ questions: [String], _ errorString: String?) -> Void) {
        let urlString = API.Constants.QUIZ_URL + id + "/0"
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
            
            guard let questionsDict = parsedResponse["questions"] as? [[String:Any]] else {
                print("Cannot find keys 'questions' in parsedResponse")
                return
            }
//            print(questionsDict)
            var questions = [String]()
            
            for question in questionsDict {
                if let text = question["text"] as? String  {
                    //                    print(title)
                    questions.append(text)
                    
                }

            }
            print(questions)
            completionHandler(true, questions, nil)
            
        }
        task.resume()
    }
}
