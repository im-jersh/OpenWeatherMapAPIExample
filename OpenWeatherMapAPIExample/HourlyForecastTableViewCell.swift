//
//  HourlyForecastTableViewCell.swift
//  OpenWeatherMapAPIExample
//
//  Created by Joshua O'Steen on 1/5/17.
//  Copyright © 2017 Joshua O'Steen. All rights reserved.
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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
