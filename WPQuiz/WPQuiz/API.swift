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
    
    func downloadListOfQuizzes(completionHandler: @escaping (_ success: Bool, _ quizzes: AnyObject, _ errorString: String?) -> Void) {
        
        let urlString = API.Constants.BASE_URL
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
            var parsedResponse = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! AnyObject
//
//            print(parsedResponse)
            
//            do {
//                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any]
//                let items = json["items"] as? [[String: Any]] ?? []
//                print(items)
//            } catch let error as NSError {
//                print(error)
//            }
        
            
            guard let items = parsedResponse["items"] as? [[String:Any]] else {
                print("Cannot find keys 'items' in parsedResponse")
                return
            }
//
//            print(items)
            
            for item in items {
                if let title = item["title"] as? String  {
                    print(title)
                }
                if let photoDict = item["mainPhoto"] as? [String:Any]  {
//                    print(photo)
                    for photo in photoDict {
                        if let url = photoDict["url"] as? String  {
                            print(url)
                        }
                    }
                }
            }

//
//            guard let buttonStart = items["buttonStart"] else {
//                print("Cannot find keys 'buttonStart' in itemsDictionary")
//                return
//            }
//
//            print(buttonStart)
            

        }
        task.resume()
    }
    

}
