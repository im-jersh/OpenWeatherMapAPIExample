//
//  HourlyForecastTableViewController.swift
//  OpenWeatherMapAPIExample
//
//  Created by Joshua O'Steen on 1/5/17.
//  Copyright © 2017 Joshua O'Steen. All rights reserved.
//

import UIKit
import CoreData

class HourlyForecastTableViewController: UITableViewController {

    var forecastForDay : OpenWeatherDailyForecast!
    var hourlyForecasts : [OpenWeatherThreeHourForecast] = []
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
        }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // fetch forecast records
        self.fetchHourlyForecastData()

        // set the view controllers nav item title
        self.title = forecastForDay.weekday
        
    }
    
// MARK: CORE DATA
    func fetchHourlyForecastData() {
        
        // Do some initial calculation to determine the beginning and end times of the
        // currently selected day. The forecastForDay object contains a double var that
        // represents the day/time and all times will be 12pm CST. To determine boundary
        // times for the core data fetch, we will add and subtract a half day's worth of
        // seconds to this time, effectively making our range 12am the same day to 12am
        // the next day
        let time = forecastForDay.day
        let lowerBound = time - 43201
        let upperBound = time + 43199
        
        // Set up the request, its predicate, and sort descriptor
        let request = NSFetchRequest<OpenWeatherThreeHourForecast>(entityName: "OpenWeatherThreeHourForecast")
        let sortDescriptor = NSSortDescriptor(key: "day", ascending: true)
        let predicate = NSPredicate(format: "day >= %lf && day <= %lf", lowerBound, upperBound)
        
        request.sortDescriptors = [sortDescriptor]
        request.predicate = predicate
        
        // fetch the records
        do {
            // attempt to fetch
            let records = try self.managedObjectContext.fetch(request) 
            
            if !records.isEmpty {
                self.hourlyForecasts = records.map({ $0 as OpenWeatherThreeHourForecast })
            }
            
        } catch let error as NSError {
            print("Error fetching hourly forecasts from Core Data: %@", error.localizedDescription)
        }
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.hourlyForecasts.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "hourlyForecastCell", for: indexPath as IndexPath) as! HourlyForecastTableViewCell

        // get the appropriate forecast object for this cell
        let data = self.hourlyForecasts[indexPath.row]
        
        // extract the forecast's time for the label text
        let date = Date(timeIntervalSince1970: data.day)
        let formatter = DateFormatter()
        if let timezone = TimeZone(abbreviation: "CST") {
            formatter.timeZone = timezone
        }
        
        formatter.dateFormat = "h:mma"
        
        cell.hourLabel.text = formatter.string(from: date)
        
        if let temp = data.temp {
            cell.tempLabel.text = temp

        }
        
        if let humidity = data.humidity {
            cell.humidityLabel.text = humidity + "%"
        }
        
        if let windSpeed = data.windSpeed {
            cell.windLabel.text = windSpeed + "mph"
        }
        
        if let icon = data.icon {
            cell.iconImageView.image = UIImage(named: icon)
        }
        
        if let main = data.main {
            cell.descriptionLabel.text = main
        }
        
        cell.backgroundColor = UIColor(red: 51.0/255.0, green: 51.0/255.0, blue: 51.0/255.0, alpha: 1.0)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.separatorInset = UIEdgeInsets.zero
        self.tableView.layoutMargins = UIEdgeInsets.zero
    }

}
