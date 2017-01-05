//
//  OpenWeather.swift
//  GoMizzou
//
//  Created by Josh O'Steen on 1/19/16.
//  Copyright © 2016 University of Missouri. All rights reserved.
//

import Foundation
import CoreData


class OpenWeather: NSManagedObject {
    
    static let degreeF = " \u{2109}"

    convenience init?(withJSON json: [String : AnyObject], inManagedObjectContext context: NSManagedObjectContext) {
        
        // Create an entity for the data
        guard let entityDescription = NSEntityDescription.entityForName("OpenWeather", inManagedObjectContext: context) else {
            print("Error creating CurrentWeather entity in \(#function)")
            return nil
        }
        
        
        self.init(entity: entityDescription, insertIntoManagedObjectContext: nil)
        
        // Extract data
        guard let weather = json["weather"] as? [AnyObject], firstObject = weather.first as? [String : AnyObject], main = firstObject["main"] as? String, desc = firstObject["description"] as? String, icon = firstObject["icon"] as? String else {
            print("Error parsing required json data to create OpenWeather object in \(#function)")
            return nil
        }
        
        guard let primaryData = json["main"] as? [String : AnyObject], temp = primaryData["temp"] as? Double else {
            print("Error parsing json to create OpenWeather object in \(#function)")
            return nil
        }
        
        guard let dt = json["dt"] as? Double else {
            print("Error parsing json to create OpenWeather object in \(#function)")
            return nil
        }
        
        // Save data to entity
        self.main = main
        self.desc = desc
        self.icon = icon
        self.temp = String(Int(temp))
        self.dt = dt
        
        if let humidity = primaryData["humidity"] as? Int {
            self.humidity = String(humidity)
        }
        
        if let pressure = primaryData["pressure"] as? Int {
            self.pressure = String(pressure)
        }
        
        if let minTemp = primaryData["temp_min"] as? Double {
            self.minTemp = String(Int(minTemp))
        }
        
        if let maxTemp = primaryData["temp_max"] as? Double {
            self.maxTemp = String(Int(maxTemp))
        }
        
        if let wind = json["wind"] as? [String : AnyObject] {
            
            if let windSpeed = wind["speed"] as? Double {
                self.windSpeed = String(Int(windSpeed))
            }
            
        }
        
        if let clouds = json["clouds"] as? [String : AnyObject] {
            
            if let cloudPerc = clouds["all"] as? Int {
                self.cloudPerc = String(cloudPerc)
            }
            
        }
        
        let formatter = NSDateFormatter()
        if let timezone = NSTimeZone(abbreviation: "CST") {
            formatter.timeZone = timezone
        }
        formatter.dateFormat = "h:mm"
        
        if let sys = json["sys"] as? [String : AnyObject] {
            
            if let rise = sys["sunrise"] as? Double {
                let sunrise = NSDate(timeIntervalSince1970: rise)
                self.sunrise = formatter.stringFromDate(sunrise)
            }
            
            if let set = sys["sunset"] as? Double {
                let sunset = NSDate(timeIntervalSince1970: set)
                self.sunset = formatter.stringFromDate(sunset)
            }
            
        }
        
        formatter.dateFormat = "h:mma 'on' MM/dd/yyyy"
        self.retrieveTime = formatter.stringFromDate(NSDate(timeIntervalSince1970: self.dt))
        
        self.lastUpdated = NSDate().timeIntervalSince1970
        
        
        
    }
    
    
}
