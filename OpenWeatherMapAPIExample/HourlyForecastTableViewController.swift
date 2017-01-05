//
//  HourlyForecastTableViewController.swift
//  GoMizzou
//
//  Created by Josh O'Steen on 10/19/15.
//  Copyright © 2015 University of Missouri. All rights reserved.
//

import UIKit

class HourlyForecastTableViewController: UITableViewController {

    var forecastForDay : OpenWeatherDailyForecast!
    var hourlyForecasts : [OpenWeatherThreeHourForecast] = []
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.managedObjectContext!
        }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // fetch forecast records
        self.fetchHourlyForecastData()

        // set the view controllers nav item title
        self.title = forecastForDay.weekday
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        let request = NSFetchRequest(entityName: "OpenWeatherThreeHourForecast")
        let sortDescriptor = NSSortDescriptor(key: "day", ascending: true)
        let predicate = NSPredicate(format: "day >= %lf && day <= %lf", lowerBound, upperBound)
        
        request.sortDescriptors = [sortDescriptor]
        request.predicate = predicate
        
        // fetch the records
        do {
            // attempt to fetch
            let records = try self.managedObjectContext.executeFetchRequest(request) as! [OpenWeatherThreeHourForecast]
            
            if !records.isEmpty {
                self.hourlyForecasts = records.map({ $0 as OpenWeatherThreeHourForecast })
            }
            
        } catch let error as NSError {
            print("Error fetching hourly forecasts from Core Data: %@", error.localizedDescription)
        }
        
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.hourlyForecasts.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("hourlyForecastCell", forIndexPath: indexPath) as! HourlyForecastTableViewCell

        // get the appropriate forecast object for this cell
        let data = self.hourlyForecasts[indexPath.row]
        
        // extract the forecast's time for the label text
        let date = NSDate(timeIntervalSince1970: data.day)
        let formatter = NSDateFormatter()
        if let timezone = NSTimeZone(abbreviation: "CST") {
            formatter.timeZone = timezone
        }
        
        formatter.dateFormat = "h:mma"
        
        cell.hourLabel.text = formatter.stringFromDate(date)
        
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
        
        cell.backgroundColor = MobileConfig.sharedManager().backgroundCol

        return cell
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.separatorInset = UIEdgeInsetsZero
        self.tableView.layoutMargins = UIEdgeInsetsZero
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
