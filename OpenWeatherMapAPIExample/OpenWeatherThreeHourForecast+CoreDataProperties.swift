//
//  OpenWeatherThreeHourForecast+CoreDataProperties.swift
//  OpenWeatherMapAPIExample
//
//  Created by Joshua O'Steen on 1/5/17.
//  Copyright © 2017 Joshua O'Steen. All rights reserved.
//

import Foundation
import CoreData


extension OpenWeatherThreeHourForecast {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<OpenWeatherThreeHourForecast> {
        return NSFetchRequest<OpenWeatherThreeHourForecast>(entityName: "OpenWeatherThreeHourForecast");
    }

    @NSManaged public var cloudPerc: String?
    @NSManaged public var day: Double
    @NSManaged public var dayText: String?
    @NSManaged public var desc: String?
    @NSManaged public var humidity: String?
    @NSManaged public var icon: String?
    @NSManaged public var main: String?
    @NSManaged public var maxTemp: String?
    @NSManaged public var minTemp: String?
    @NSManaged public var pressure: String?
    @NSManaged public var temp: String?
    @NSManaged public var windSpeed: String?

}
