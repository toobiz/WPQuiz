//
//  MainViewController.swift
//  WPQuiz
//
//  Created by Michał Tubis on 06.03.2017.
//  Copyright © 2017 Mike Tubis. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var quizzes = [String]()
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view, typically from a nib.
        API.sharedInstance().downloadListOfQuizzes { (success, quizzes, error) in
            print(quizzes)
            self.quizzes = quizzes
            DispatchQueue.main.async() {
                self.tableView.reloadData()
            }
        }
        
    }

    // MARK: - TableView delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quizzes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath as IndexPath)
        var title = String()
        if quizzes.count > 0 {
            title = quizzes[indexPath.row]
        }
        cell.textLabel?.text = title
        //        cell.imageView?.image = UIImage(named: "pin.png")
        //        cell.detailTextLabel?.text = userInformation.mediaURL!
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let userInformation = Users.sharedInstance().users[indexPath.row]
//        let userLink = userInformation.mediaURL!
//        if userLink.rangeOfString("http") != nil {
//            UIApplication.sharedApplication().openURL(NSURL(string: "\(userLink)")!)
//        } else {
//            showAlert("Invalid link")
//        }
    }
    
//    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
//        let userInformation = Users.sharedInstance().users[indexPath.row]
//        let objectId = userInformation.objectId!
//        tableView.beginUpdates()
//        Users.sharedInstance().users.removeAtIndex(indexPath.row)
//        ParseClient.sharedInstance().deleteStudentLocation(objectId)
//        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
//        tableView.endUpdates()
//        print("Deleted object \(objectId)")
//    }


}

