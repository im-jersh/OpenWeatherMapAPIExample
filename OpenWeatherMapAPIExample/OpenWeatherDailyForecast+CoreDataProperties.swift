//
//  OpenWeatherDailyForecast+CoreDataProperties.swift
//  GoMizzou
//
//  Created by Josh O'Steen on 1/19/16.
//  Copyright © 2016 University of Missouri. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension OpenWeatherDailyForecast {

    @NSManaged var cloudPerc: String?
    @NSManaged var day: Double
    @NSManaged var desc: String?
    @NSManaged var humidity: String?
    @NSManaged var icon: String?
    @NSManaged var main: String?
    @NSManaged var maxTemp: String?
    @NSManaged var minTemp: String?
    @NSManaged var pressure: String?
    @NSManaged var weekday: String?
    @NSManaged var windSpeed: String?

}
