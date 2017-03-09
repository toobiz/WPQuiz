//
//  ResultViewController.swift
//  WPQuiz
//
//  Created by Michał Tubis on 09.03.2017.
//  Copyright © 2017 Mike Tubis. All rights reserved.
//

import UIKit

class ResultViewController: UIViewController {

    var totalScore = Float()
    
    @IBOutlet var resultTitleLabel: UILabel!
    @IBOutlet var resultScoreLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resultScoreLabel.text = String(Int(totalScore * 100)) + "%"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func goToList(_ sender: Any) {
    }
    
    @IBAction func tryAgain(_ sender: Any) {
    }
    

}
