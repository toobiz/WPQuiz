//
//  QuizViewController.swift
//  WPQuiz
//
//  Created by Michał Tubis on 07.03.2017.
//  Copyright © 2017 Mike Tubis. All rights reserved.
//

import UIKit

class QuizViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var currentPage = Int()
    var questions = [Question]()
    var quiz : Quiz!
    
    @IBOutlet var questionLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    
    @IBAction func endButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        API.sharedInstance().downloadQuiz(quiz: quiz) { (success, questions, error) in
            if success == true {
                self.questions = questions
                DispatchQueue.main.async(execute: {
                    self.questionLabel.text = questions[self.currentPage].text
                    self.currentPage = 0
                    self.tableView.reloadData()
                });
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showNextQuestion(_ sender: Any) {
        if questions.count > currentPage + 1 {
            questionLabel.text = questions[currentPage + 1].text
            currentPage = currentPage + 1
            tableView.reloadData()
        } else {
            print("Koniec")
        }
    }
    
    // MARK: - TableView delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AnswerCell", for: indexPath as IndexPath)
        
        if questions.count > 0 {
            let question = questions[currentPage]
            let answers = question.answers
            cell.textLabel?.text = answers[indexPath.row].text
        }

        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }

}
