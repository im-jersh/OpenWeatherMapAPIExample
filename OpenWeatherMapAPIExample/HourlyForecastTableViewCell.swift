//
//  HourlyForecastTableViewCell.swift
//  GoMizzou
//
//  Created by Josh O'Steen on 10/19/15.
//  Copyright © 2015 University of Missouri. All rights reserved.
//

import UIKit

class HourlyForecastTableViewCell: UITableViewCell {

    
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
