//
//  SigfoodTableViewCell.swift
//  Sigfood
//
//  Created by Kett, Oliver on 04.03.15.
//  Copyright (c) 2015 Kett, Oliver. All rights reserved.
//

import UIKit

class SigfoodTableViewCell: UITableViewCell {
    
    var data: Menu?
    
    @IBOutlet weak var mainCourseLabel: UILabel!
    @IBOutlet weak var priceGuest: UILabel!
    @IBOutlet weak var priceStaff: UILabel!
    @IBOutlet weak var priceStud: UILabel!
    @IBOutlet weak var foodImage: UIImageView!
    
    @IBOutlet weak var star1: UIImageView!
    @IBOutlet weak var star2: UIImageView!
    @IBOutlet weak var star3: UIImageView!
    @IBOutlet weak var star4: UIImageView!
    @IBOutlet weak var star5: UIImageView!

}
