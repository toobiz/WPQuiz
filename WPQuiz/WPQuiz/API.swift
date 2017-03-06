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
    
    // MARK: - All purpose task method for data
    
    func taskForResource(resource: String, parameters: [String : AnyObject], completionHandler: CompletionHander) -> URLSessionDataTask {
        
        var mutableParameters = parameters
        var mutableResource = resource
        
        // Add in the API Key
        mutableParameters["api_key"] = Constants.ApiKey
        
        // Substitute the id parameter into the resource
        if resource.rangeOfString(":id") != nil {
            assert(parameters[Keys.ID] != nil)
            
            mutableResource = mutableResource.stringByReplacingOccurrencesOfString(":id", withString: "\(parameters[Keys.ID]!)")
            mutableParameters.removeValueForKey(Keys.ID)
        }
        
        let urlString = Constants.BaseUrlSSL + mutableResource + TheMovieDB.escapedParameters(mutableParameters)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        print(url)
        
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            if let error = downloadError {
                let newError = TheMovieDB.errorForData(data, response: response, error: error)
                completionHandler(result: nil, error: newError)
            } else {
                print("Step 3 - taskForResource's completionHandler is invoked.")
                TheMovieDB.parseJSONWithCompletionHandler(data!, completionHandler: completionHandler)
            }
        }
        
        task.resume()
        
        return task
    }
}
