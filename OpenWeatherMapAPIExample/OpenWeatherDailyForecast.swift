//
//  OpenWeatherDailyForecast.swift
//  GoMizzou
//
//  Created by Josh O'Steen on 1/19/16.
//  Copyright © 2016 University of Missouri. All rights reserved.
//

import Foundation
import CoreData


class OpenWeatherDailyForecast: NSManagedObject {

    convenience init?(withJSON json: [String : AnyObject], inManagedObjectContext context: NSManagedObjectContext) {
     
        // Create an entity for the data
        guard let entityDescription = NSEntityDescription.entityForName("OpenWeatherDailyForecast", inManagedObjectContext: context) else {
            print("Error creating DailyWeather entity in \(#function)")
            return nil
        }
        
        self.init(entity: entityDescription, insertIntoManagedObjectContext: nil)
        
        // Extract data
        guard let weather = json["weather"] as? [AnyObject], firstObject = weather.first as? [String : AnyObject], main = firstObject["main"] as? String, desc = firstObject["description"] as? String, icon = firstObject["icon"] as? String, dt = json["dt"] as? Double else {
            print("Error parsing required json data to create DailyForecast object in \(#function)")
            return nil
        }
        
        self.main = main
        self.desc = desc
        self.icon = icon
        self.day = dt
        
        if let humidity = json["humidity"] as? Int {
            self.humidity = String(humidity)
        }
        
        if let pressure = json["pressure"] as? Int {
            self.pressure = String(pressure)
        }
        
        if let temp = json["temp"] as? [String : AnyObject] {
            
            if let minTemp = temp["min"] as? Double {
                self.minTemp = String(Int(minTemp))
            }
            
            if let maxTemp = temp["max"] as? Double {
                self.maxTemp = String(Int(maxTemp))
            }
            
        }
        
        if let windSpeed = json["speed"] as? Double {
            self.windSpeed = String(Int(windSpeed))
        }
        
        if let cloudPerc = json["clouds"] as? Int {
            self.cloudPerc = String(cloudPerc)
        }
        
        let formatter = NSDateFormatter()
        if let timezone = NSTimeZone(abbreviation: "CST") {
            formatter.timeZone = timezone
        }
        formatter.dateFormat = "EEEE"
        
        self.weekday = formatter.stringFromDate(NSDate(timeIntervalSince1970: self.day))
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
