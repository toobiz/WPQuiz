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
    var totalScore = Int()
    var answerIsChosen = false
    
    @IBOutlet var questionLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var progressView: UIProgressView!
    
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
                    self.updateProgress()
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
            updateProgress()
            tableView.reloadData()
            answerIsChosen = false
        } else {
            print("Koniec")
            print("Twój wynik:  \(totalScore)")
        }
    }
    
    func updateProgress() {
        var totalPages = Int()
        if questions.count > 0 {
            totalPages = questions.count
        } else {
            totalPages = 0
        }
        progressView?.progress = Float(currentPage + 1) / Float(totalPages)
    }
    
    // MARK: - TableView delegate
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if questions.count > 0 {
            return questions[currentPage].answers.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.register(UINib(nibName: "AnswerCell", bundle: nil), forCellReuseIdentifier: "AnswerCell")
        tableView.allowsMultipleSelection = false
        let cell = tableView.dequeueReusableCell(withIdentifier: "AnswerCell", for: indexPath as IndexPath) as! AnswerCell
        cell.accessoryType = .none
        
        if questions.count > 0 {
            let question = questions[currentPage]
            let answers = question.answers
            cell.label.text = answers[indexPath.row].text
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        let cell = tableView.dequeueReusableCell(withIdentifier: "AnswerCell", for: indexPath)
//        tableView.deselectRow(at: indexPath, animated: true)
//        if let cell = tableView.cellForRow(at: indexPath) {
//        }
        let question = questions[currentPage]
        let answer = question.answers[indexPath.row]
        let isCorrect = answer.isCorrect
        if isCorrect == true {
            if answerIsChosen == false {
                print("Wybrano poprawną odpowiedź")
                totalScore += 1
                answerIsChosen = true
            }
        }
        if isCorrect == false {
            print("Niepoprawna odpowiedź")
            if answerIsChosen == true {
                totalScore -= 1
                print("Odznaczono poprawną odpowiedź")
                answerIsChosen = false
            }
        }
        print(totalScore)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
    }

}
