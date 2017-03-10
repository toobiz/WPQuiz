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
    var fetchedPage = Int()
    var questions = [Question]()
    var quizId = NSNumber()
    var quiz : Quiz!
    var totalScore = Float()
    var finalScore = Float()
    var totalProgress = Float()
    var quizView = QuizView()
    var resultView = ResultView()

    @IBOutlet var contentView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resultView = (Bundle.main.loadNibNamed("ResultView", owner: self, options: nil)?.first as? ResultView)!
        quizView = (Bundle.main.loadNibNamed("QuizView", owner: self, options: nil)?.first as? QuizView)!
        
        quizView.tableView.delegate = self
        quizView.tableView.dataSource = self
        
        quizView.progressView?.progress = 0
        
        let fetchResult = fetchQuiz()
        let quiz = fetchResult[0]
        
        API.sharedInstance().downloadQuiz(quiz: quiz) { (success, questions, error) in
            if success == true {
                self.questions = questions
                DispatchQueue.main.async(execute: {

//                    self.totalScore = Float(self.quiz.score)
                    self.currentPage = Int(Float(quiz.progress!)/Float(self.questions.count))
//                    self.currentPage = self.fetchedPage
//                    self.saveProgress()
//                    self.currentPage = 0
                    self.updateView()
                });
            }
        }
    }
    
    func updateView() {
        
        if currentPage >= questions.count {
            contentView.addSubview(resultView)
            saveScore()
        } else {
            contentView.addSubview(quizView)
            reloadQuizData()
        }
    }
    
    func reloadQuizData() {
        
        quizView.questionLabel.text = questions[currentPage].text
        quizView.tableView.reloadData()
        quizView.progressView?.progress = setProgress()
    }
    
    func saveScore() {
        
        let fetchResult = fetchQuiz()
        let fetchedQuiz = fetchResult[0]
        fetchedQuiz.setValue(NSNumber(value: round(setScore()*100)), forKey: "score")
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    func saveProgress() {
        
        let fetchResult = fetchQuiz()
        let fetchedQuiz = fetchResult[0]
        fetchedQuiz.setValue(NSNumber(value: round(setProgress()*100)), forKey: "progress")
        CoreDataStackManager.sharedInstance().saveContext()
        print(totalProgress)
    }
    
    func setProgress() -> Float {
        let totalPages = questions.count
        totalProgress = Float(currentPage) / Float(totalPages)
        return totalProgress
    }
    
    func setScore() -> Float {
        let finalScore = totalScore/Float(questions.count)
        return finalScore
    }
    
    // MARK: - TableView delegate

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if questions.count > 0 && currentPage < questions.count {
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

//        print(totalScore)
        if currentPage < questions.count {
            currentPage = currentPage + 1
        }
        
        saveProgress()
        updateView()
    }
    
    // MARK: - Core Data
    
    lazy var sharedContext: NSManagedObjectContext =  {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    func fetchQuiz() -> [Quiz] {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Quiz")
        let predicate = NSPredicate(format: "%K == %@", "id", quizId)
        fetchRequest.predicate = predicate
        
        do {
            return try sharedContext.fetch(fetchRequest) as! [Quiz]
        } catch  let error as NSError {
            print("Error in fetchAllQuizzes(): \(error)")
            return [Quiz]()
        }
    }

}
