//
//  QuizViewController.swift
//  WPQuiz
//
//  Created by Michał Tubis on 07.03.2017.
//  Copyright © 2017 Mike Tubis. All rights reserved.
//

import UIKit
import CoreData

class QuizViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var currentPage = Int()
    var questions = [Question]()
    var quiz : Quiz!
    var totalScore = Float()
    var quizView = QuizView()
    var resultView = ResultView()

    @IBOutlet var contentView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        quizView = (Bundle.main.loadNibNamed("QuizView", owner: self, options: nil)?.first as? QuizView)!
        resultView = (Bundle.main.loadNibNamed("ResultView", owner: self, options: nil)?.first as? ResultView)!
        
        quizView.tableView.delegate = self
        quizView.tableView.dataSource = self
        
//        progressView?.progress = 0
        
        API.sharedInstance().downloadQuiz(quiz: quiz) { (success, questions, error) in
            if success == true {
                self.questions = questions
                DispatchQueue.main.async(execute: {
//                    self.quizView.questionLabel.text = questions[self.currentPage].text
//                    self.quizView.tableView.reloadData()
                    self.currentPage = Int(Float(self.quiz.progress!)/Float(self.questions.count))
                    self.updateProgress()
                    self.reloadQuizData()
                    self.updateView()
                });
            }
        }
    }
    
    func updateView() {
        
        if currentPage == questions.count {
            contentView.addSubview(resultView)
        } else {
            contentView.addSubview(quizView)
        }
    }
    
    func reloadQuizData() {
        
        if currentPage == questions.count {
            saveFinalScore()
        } else {
            quizView.questionLabel.text = questions[currentPage].text
            quizView.tableView.reloadData()
        }
    }
    
    func saveFinalScore() {
        let finalScore = totalScore/Float(questions.count)
        //            resultView.totalScore = Float(finalScore)
        //            resultView.quizView = self
        //            self.present(resultView, animated: true, completion: nil)
        
        let fetchResult = fetchQuiz()
        let fetchedQuiz = fetchResult[0]
        fetchedQuiz.setValue(NSNumber(value: round(finalScore * 100)), forKey: "score")
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    func updateProgress() {
        var totalPages = Int()
        var totalProgress = Float()
        
        if questions.count > 0 {
            totalPages = questions.count
            totalProgress = Float(currentPage) / Float(totalPages)

            let fetchResult = fetchQuiz()
            let fetchedQuiz = fetchResult[0]
            fetchedQuiz.setValue(NSNumber(value: round(totalProgress * 100)), forKey: "progress")
            CoreDataStackManager.sharedInstance().saveContext()
            print(totalProgress)
        } else {
            totalPages = 0
        }
        quizView.progressView?.progress = totalProgress
    }
    
    // MARK: - TableView delegate

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if questions.count > 0 {
            return questions[currentPage].answers.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.register(UINib(nibName: "AnswerCell", bundle: nil), forCellReuseIdentifier: "AnswerCell")
        tableView.allowsMultipleSelection = false
        let cell = tableView.dequeueReusableCell(withIdentifier: "AnswerCell", for: indexPath as IndexPath) as! AnswerCell
        
        if questions.count > 0 {
            let question = questions[currentPage]
            let answers = question.answers
            cell.label.text = answers[indexPath.row].text
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let question = questions[currentPage]
        let answer = question.answers[indexPath.row]
        let isCorrect = answer.isCorrect
        if isCorrect == true {
                totalScore += 1
        }

        print(totalScore)
        
        currentPage = currentPage + 1
        updateProgress()
        reloadQuizData()
        updateView()
    }
    
    // MARK: - Core Data
    
    lazy var sharedContext: NSManagedObjectContext =  {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    func fetchQuiz() -> [Quiz] {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Quiz")
        let predicate = NSPredicate(format: "%K == %@", "id", quiz.id)
        fetchRequest.predicate = predicate
        
        do {
            return try sharedContext.fetch(fetchRequest) as! [Quiz]
        } catch  let error as NSError {
            print("Error in fetchAllQuizzes(): \(error)")
            return [Quiz]()
        }
    }

}
