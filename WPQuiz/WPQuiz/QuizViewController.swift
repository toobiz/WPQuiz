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
    var quizId = NSNumber()
    var quiz : Quiz!
    var totalScore = Float()
    var fetchedScore = Int()
    var totalProgress = Float()
    var quizView = QuizView()
    var resultView = ResultView()

    @IBOutlet var contentView: UIView!
    
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

    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resultView = (Bundle.main.loadNibNamed("ResultView", owner: self, options: nil)?.first as? ResultView)!
        quizView = (Bundle.main.loadNibNamed("QuizView", owner: self, options: nil)?.first as? QuizView)!
        
        quizView.tableView.delegate = self
        quizView.tableView.dataSource = self
        quizView.progressView?.progress = 0
        
        quizView.frame = view.bounds
        resultView.frame = view.bounds
        
        resultView.goToListButton.addTarget(self, action: #selector(goToList), for: .touchUpInside)
        resultView.tryAgainButton.addTarget(self, action: #selector(tryAgain), for: .touchUpInside)
        
        downloadQuiz()
    }
    
    // MARK: - Functions
    
    func downloadQuiz() {
        
        let fetchResult = fetchQuiz()
        let quiz = fetchResult[0]
        
        API.sharedInstance().downloadQuiz(quiz: quiz) { (success, questions, error) in
            if success == true {
                self.questions = questions
                DispatchQueue.main.async(execute: {
                    
                    if quiz.score != 0 {
                        self.totalScore = Float(quiz.score)
                    }
                    self.currentPage = Int(quiz.currentPage)
                    self.fetchedScore = Int(quiz.score)
                    self.updateView()
                });
            }
        }
    }
    
    func goToList() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func tryAgain() {
        currentPage = 0
        totalScore = 0
        contentView.addSubview(quizView)
        reloadQuizData()
    }
    
    func updateView() {
        
        if currentPage >= questions.count {
            contentView.addSubview(resultView)
            reloadResultData()
        } else {
            contentView.addSubview(quizView)
            reloadQuizData()
        }
    }
    
    func reloadQuizData() {
        self.quizView.imageView.image = nil

        if (questions[self.currentPage].imageUrl != "") {
            
            DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async(execute: { () -> Void in
                let imageString = self.questions[self.currentPage].imageUrl
                let imageURL = URL(string: imageString)
                if let data = try? Data(contentsOf: imageURL!) {
                    
                    DispatchQueue.main.async(execute: {
                        self.quizView.imageView.image = UIImage(data: data)
                    });
                }
            })
        }
        quizView.questionLabel.text = questions[currentPage].text
        quizView.tableView.reloadData()
        quizView.progressView?.progress = setProgress()
    }
    
    func reloadResultData() {
        var scoreString = String()
        if totalScore == 0 {
            scoreString = String(describing: fetchedScore) + "%"
        } else {
            scoreString = String(describing: Int(round(setScore()*100))) + "%"
        }
        resultView.resultScoreLabel.text = scoreString
    }
    
    func saveScore() {
        let fetchResult = fetchQuiz()
        let fetchedQuiz = fetchResult[0]
        fetchedQuiz.setValue(totalScore, forKey: "score")
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    func saveProgress() {
        let fetchResult = fetchQuiz()
        let fetchedQuiz = fetchResult[0]
        fetchedQuiz.setValue(NSNumber(value: round(setProgress()*100)), forKey: "progress")
        fetchedQuiz.setValue(currentPage, forKey: "currentPage")
        fetchedQuiz.setValue(questions.count, forKey: "questionsCount")
        CoreDataStackManager.sharedInstance().saveContext()
        print("Total progress is: \(totalProgress)")
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
            print("Correct answer")
        } else {
            print("Incorrect answer")
        }

        print("Total score: \(totalScore)")
        if currentPage < questions.count {
            currentPage += 1
        }
        saveScore()
        saveProgress()
        updateView()
    }
    
}
