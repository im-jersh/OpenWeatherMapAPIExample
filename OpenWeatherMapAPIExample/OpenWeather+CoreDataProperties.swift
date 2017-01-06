//
//  OpenWeather+CoreDataProperties.swift
//  OpenWeatherMapAPIExample
//
//  Created by Joshua O'Steen on 1/5/17.
//  Copyright © 2017 Joshua O'Steen. All rights reserved.
//

import Foundation
import CoreData


extension OpenWeather {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<OpenWeather> {
        return NSFetchRequest<OpenWeather>(entityName: "OpenWeather");
    }

    @NSManaged public var cloudPerc: String?
    @NSManaged public var desc: String?
    @NSManaged public var dt: Double
    @NSManaged public var humidity: String?
    @NSManaged public var icon: String?
    @NSManaged public var lastUpdated: Double
    @NSManaged public var main: String?
    @NSManaged public var maxTemp: String?
    @NSManaged public var minTemp: String?
    @NSManaged public var pressure: String?
    @NSManaged public var retrieveTime: String?
    @NSManaged public var sunrise: String?
    @NSManaged public var sunset: String?
    @NSManaged public var temp: String?
    @NSManaged public var windSpeed: String?

}
