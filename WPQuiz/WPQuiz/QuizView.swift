//
//  QuizView.swift
//  WPQuiz
//
//  Created by Michał Tubis on 10.03.2017.
//  Copyright © 2017 Mike Tubis. All rights reserved.
//

import UIKit

class QuizView: UIView {

    @IBOutlet var questionLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var progressView: UIProgressView!
    
    override func layoutSubviews() {
        
//        progressView.progress = 0
    }

}
