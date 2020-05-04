//
//  MainTableViewCell.swift
//  Naganitara
//
//  Created by User on 21/03/2020.
//  Copyright © 2020 Naganitara. All rights reserved.
//

import UIKit

class MainTableViewCell: UITableViewCell {

    var isOpen = false
    
    @IBOutlet weak var starBtn: UIButton!
    @IBOutlet weak var headLine: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBAction func star(_ sender: Any) {
        if isOpen  {
            isOpen = false
             let image = UIImage(named: "star")
             starBtn.setImage(image, for: .normal)
             UIView.transition(with: starBtn, duration: 0.3, options:.transitionCrossDissolve, animations: nil, completion: nil)
            
        } else{
             isOpen = true
            let image = UIImage(named: "star_fav")
            starBtn.setImage(image, for: .normal)
            UIView.transition(with: starBtn, duration: 0.3, options: .transitionFlipFromRight, animations: nil, completion: nil)
        }
    }
    
}
