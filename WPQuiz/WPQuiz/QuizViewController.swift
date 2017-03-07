//
//  QuizViewController.swift
//  WPQuiz
//
//  Created by Michał Tubis on 07.03.2017.
//  Copyright © 2017 Mike Tubis. All rights reserved.
//

import UIKit

class QuizViewController: UIViewController {
    
    var currentPage = Int()
    var questions = [String]()
    
    @IBOutlet var questionLabel: UILabel!
    
    @IBAction func endButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        API.sharedInstance().downloadQuiz(id: "6087919785886849") { (success, questions, error) in
            if success == true {
                print(questions)
                self.questions = questions
                DispatchQueue.main.async(execute: {
                    self.questionLabel.text = questions[0]
                    self.currentPage = 0
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
            questionLabel.text = questions[currentPage + 1]
            currentPage = currentPage + 1
        } else {
            print("Koniec")
        }
    }
    

}
