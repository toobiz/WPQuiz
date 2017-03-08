//
//  MainViewController.swift
//  WPQuiz
//
//  Created by Michał Tubis on 06.03.2017.
//  Copyright © 2017 Mike Tubis. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var quizzes = [Quiz]()

    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view, typically from a nib.
        API.sharedInstance().downloadListOfQuizzes { (success, quizzes, error) in
            // print(quizzes)
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.register(UINib(nibName: "QuizCell", bundle: nil), forCellReuseIdentifier: "QuizCell")
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuizCell", for: indexPath as IndexPath) as! QuizCell
        
        let quiz = quizzes[indexPath.row]
        var titleString = String()
        
            if quizzes.count > 0 {
            titleString = quiz.title
        }
        cell.quizTitle.text = titleString
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async(execute: { () -> Void in
            
            let imageString = quiz.url
            let imageURL = URL(string: imageString)
            if let data = try? Data(contentsOf: imageURL!) {
                
                DispatchQueue.main.async(execute: {
                    cell.quizPhoto.image = UIImage(data: data)
                });
                
            } else {
//                show placeholder
            }
        })
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let quiz = quizzes[indexPath.row]
        
        let quizView = self.storyboard!.instantiateViewController(withIdentifier: "Quiz") as! QuizViewController
        quizView.quiz = quiz
        let navController = UINavigationController(rootViewController: quizView)
        self.present(navController, animated: true, completion: nil)
    }

}

