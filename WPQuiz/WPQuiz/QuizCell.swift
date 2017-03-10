//
//  QuizCell.swift
//  WPQuiz
//
//  Created by Michał Tubis on 07.03.2017.
//  Copyright © 2017 Mike Tubis. All rights reserved.
//

import UIKit

class QuizCell: UITableViewCell {

    @IBOutlet var quizTitle: UILabel!
    @IBOutlet var progressLabel: UILabel!
    @IBOutlet var quizPhoto: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
