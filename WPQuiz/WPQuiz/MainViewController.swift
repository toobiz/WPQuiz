//
//  MainViewController.swift
//  WPQuiz
//
//  Created by Michał Tubis on 06.03.2017.
//  Copyright © 2017 Mike Tubis. All rights reserved.
//

import UIKit
import CoreData

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var quizzes = [Quiz]()

    @IBOutlet var tableView: UITableView!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.quizzes = fetchAllQuizzes()

        API.sharedInstance().downloadListOfQuizzes { (success, quizzes, error) in
            self.quizzes = quizzes
            DispatchQueue.main.async() {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        tableView.reloadData()
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
        cell.selectionStyle = .none
        cell.progressLabel.isHidden = true
        
        let quiz = quizzes[indexPath.row]
        var titleString = String()
        var progressString = String()
        
        if quizzes.count > 0 {
            titleString = quiz.title
            
            if Float(quiz.progress!) > 0 {
                cell.progressLabel.isHidden = false
                print("\(quiz.title) ma progress")
                progressString = "Quiz rozwiązany w " + String(describing: quiz.progress!) + "%"
                cell.progressLabel.text = progressString
            }
            if Int(quiz.score) > 0 {
                progressString = "Ostatni wynik: " + String(describing: quiz.score) + "%"
                cell.progressLabel.text = progressString
            }
            
            cell.quizTitle.text = titleString
        }
        
        
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
        quizView.quizId = quiz.id
//        let navController = UINavigationController(rootViewController: quizView)
        navigationController?.pushViewController(quizView, animated: true)
        print("Wybrano quiz no. \(quiz.id)")
    }

}

