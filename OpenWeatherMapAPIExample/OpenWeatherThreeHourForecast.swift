//
//  OpenWeatherThreeHourForecast.swift
//  GoMizzou
//
//  Created by Josh O'Steen on 1/21/16.
//  Copyright © 2016 University of Missouri. All rights reserved.
//

import Foundation
import CoreData


class OpenWeatherThreeHourForecast: NSManagedObject {

    convenience init?(withJSON json: [String : Any], inManagedObjectContext context: NSManagedObjectContext) {
        
        // Create an entity for the data
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "OpenWeatherThreeHourForecast", in: context) else {
            print("Error creating HourlyForecast entity in \(#function)")
            return nil
        }
        
        self.init(entity: entityDescription, insertInto: nil)
        
        guard let weather = json["weather"] as? [Any], let firstObject = weather.first as? [String : Any], let main = json["main"] as? [String : Any], let weatherMain = firstObject["main"] as? String, let weatherIcon = firstObject["icon"] as? String, let weatherDesc = firstObject["description"] as? String else {
            print("Error parsing required json data to create DailyForecast object in \(#function)")
            return nil
        }
        
        self.main = weatherMain
        self.desc = weatherDesc
        self.icon = weatherIcon
        
        if let temp = main["temp"] as? Double {
            self.temp = String(Int(temp))
        }
        
        if let humidity = main["humidity"] as? Int {
            self.humidity = String(humidity)
        }
        
        if let pressure = main["pressure"] as? Double {
            self.pressure = String(Int(pressure))
        }
        
        if let min = main["temp_min"] as? Double, let max = main["temp_max"] as? Double {
            self.minTemp = String(Int(min))
            self.maxTemp = String(Int(max))
        }
        
        if let wind = json["wind"] as? [String : Any], let speed = wind["speed"] as? Double {
            self.windSpeed = String(Int(speed))
        }
        
        if let clouds = json["clouds"] as? [String : Any], let all = clouds["all"] as? Int {
            self.cloudPerc = String(all)
        }
        
        if let dt = json["dt"] as? Double {
            self.day = dt
        }
        
        if let dayText = json["dt_txt"] as? String {
            self.dayText = dayText
        }

        
    }

}
