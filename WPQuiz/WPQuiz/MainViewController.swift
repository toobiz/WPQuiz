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
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.quizzes = fetchAllQuizzes()
        quizzes.sort(by: {Int($1.id) < Int($0.id) })

        API.sharedInstance().downloadListOfQuizzes { (success, quizzes, error) in
            self.quizzes = quizzes
            self.quizzes.sort(by: {Int($1.id) < Int($0.id) })
            DispatchQueue.main.async() {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tableView.reloadData()
    }

    // MARK: - TableView delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quizzes.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.frame.size.height / 2.3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.register(UINib(nibName: "QuizCell", bundle: nil), forCellReuseIdentifier: "QuizCell")
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuizCell", for: indexPath as IndexPath) as? QuizCell

            cell?.quizPhoto.image = nil
            
            cell?.selectionStyle = .none
            cell?.progressLabel.isHidden = true
            
            let quiz = quizzes[indexPath.row]
            var titleString = String()
            var progressString = String()
            
            if quizzes.count > 0 {
                titleString = quiz.title
                
                if Float(quiz.progress!) > 0 {
                    cell?.progressLabel.isHidden = false
                    progressString = "Quiz rozwiązany w " + String(describing: quiz.progress!) + "%"
                    cell?.progressLabel.text = progressString
                }
                if Float(quiz.score) > 0 && Float(quiz.progress!) == 100 {
                    let totalPages = quiz.questionsCount
                    let totalProgress = Float(quiz.score) / Float(totalPages)
                    progressString = "Ostatni wynik: " + String(describing: Int(round(totalProgress * 100))) + "%"
                    cell?.progressLabel.text = progressString
                }
                cell?.quizTitle.text = titleString
            }
            
            if quiz.urlString == nil || quiz.urlString == "" {
                cell?.quizPhoto.image = nil
                print("Image not available")
            } else if quiz.image != nil {
                cell?.quizPhoto.image = quiz.image!
                print("Image retrieved from cache")
            } else {
                
                API.sharedInstance().downloadImage(urlString: (quiz.urlString)!, completionHandler: { (success, image, error) in
                    if success == true {
                        
                        let resizedImage = self.imageResize(image, sizeChange: CGSize(width: 192, height: 108))
                        if let cellToUpdate = tableView.cellForRow(at: indexPath) as? QuizCell {
                            quiz.image = resizedImage
                            DispatchQueue.main.async(execute: {
                                cellToUpdate.quizPhoto.image = nil
                                cellToUpdate.quizPhoto.image = resizedImage
                                cellToUpdate.setNeedsLayout()
                            });
                        }
                    }
                })
        }

        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let quiz = quizzes[indexPath.row]
        let quizView = self.storyboard!.instantiateViewController(withIdentifier: "Quiz") as! QuizViewController
        quizView.quizId = quiz.id
        navigationController?.pushViewController(quizView, animated: true)
        print("Quiz no. \(quiz.id)")
    }
    
    // MARK: - Helpers
    
    func imageResize (_ image:UIImage, sizeChange:CGSize)-> UIImage{
        
        let hasAlpha = true
        let scale: CGFloat = 3.5
        
        UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
        image.draw(in: CGRect(origin: CGPoint.zero, size: sizeChange))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage!
    }

}

