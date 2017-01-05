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

    convenience init?(withJSON json: [String : Any], inManagedObjectContext context: NSManagedObjectContext) {
        
        // Create an entity for the data
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "OpenWeather", in: context) else {
            print("Error creating CurrentWeather entity in \(#function)")
            return nil
        }
        
        
        self.init(entity: entityDescription, insertInto: nil)
        
        // Extract data
        guard let weather = json["weather"] as? [Any], let firstObject = weather.first as? [String : Any], let main = firstObject["main"] as? String, let desc = firstObject["description"] as? String, let icon = firstObject["icon"] as? String else {
            print("Error parsing required json data to create OpenWeather object in \(#function)")
            return nil
        }
        
        guard let primaryData = json["main"] as? [String : Any], let temp = primaryData["temp"] as? Double else {
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
        
        if let wind = json["wind"] as? [String : Any] {
            
            if let windSpeed = wind["speed"] as? Double {
                self.windSpeed = String(Int(windSpeed))
            }
            
        }
        
        if let clouds = json["clouds"] as? [String : Any] {
            
            if let cloudPerc = clouds["all"] as? Int {
                self.cloudPerc = String(cloudPerc)
            }
            
        }
        
        let formatter = DateFormatter()
        if let timezone = TimeZone(abbreviation: "CST") {
            formatter.timeZone = timezone
        }
        formatter.dateFormat = "h:mm"
        
        if let sys = json["sys"] as? [String : Any] {
            
            if let rise = sys["sunrise"] as? Double {
                let sunrise = Date(timeIntervalSince1970: rise)
                self.sunrise = formatter.string(from: sunrise)
            }
            
            if let set = sys["sunset"] as? Double {
                let sunset = Date(timeIntervalSince1970: set)
                self.sunset = formatter.string(from: sunset)
            }
            
        }
        
        formatter.dateFormat = "h:mma 'on' MM/dd/yyyy"
        self.retrieveTime = formatter.string(from: Date(timeIntervalSince1970: self.dt))
        
        self.lastUpdated = NSDate().timeIntervalSince1970
        
        
        
    }
    
    
}
