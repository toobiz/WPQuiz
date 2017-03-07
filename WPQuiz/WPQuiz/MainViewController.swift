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
    var urls = [String]()

    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view, typically from a nib.
        API.sharedInstance().downloadListOfQuizzes { (success, quizzes, urls, error) in
            print(quizzes)
            self.quizzes = quizzes
            self.urls = urls
            DispatchQueue.main.async() {
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - TableView delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quizzes.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.register(UINib(nibName: "QuizCell", bundle: nil), forCellReuseIdentifier: "QuizCell")
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuizCell", for: indexPath as IndexPath) as! QuizCell
        var title = String()
        if quizzes.count > 0 {
            title = quizzes[indexPath.row]
        }
        cell.quizTitle.text = title
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async(execute: { () -> Void in
            
            let imageString = self.urls[indexPath.row]
            let imageURL = URL(string: imageString)
            if let data = try? Data(contentsOf: imageURL!) {
                
                DispatchQueue.main.async(execute: {
                    cell.quizPhoto.image = UIImage(data: data)
//                    game.image = cell.gameImage.image
                });
                
            } else {
//                cell.gameImage.image = UIImage(named: "cover_placeholder")
            }
        })
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let quizView = self.storyboard!.instantiateViewController(withIdentifier: "Quiz") as! QuizViewController
        let navController = UINavigationController(rootViewController: quizView)
        present(navController, animated: true, completion: nil)
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

