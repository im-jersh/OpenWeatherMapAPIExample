//
//  OWMViewController.swift
//  GoMizzou
//
//  Created by Josh O'Steen on 10/7/15.
//  Copyright © 2015 University of Missouri. All rights reserved.
//

import UIKit
import CoreData

@objc class OWMViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
// MARK: IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var sunriseLabel: UILabel!
    @IBOutlet weak var sunsetLabel: UILabel!
    @IBOutlet weak var cloudPercentageLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!
    @IBOutlet weak var lastUpdatedLabel: UILabel!
    @IBOutlet weak var forecastCollection: UICollectionView!
    @IBOutlet weak var highLowLabel: UILabel!
    
    var currentWeather : OpenWeather!
    var dailyForecast = [OpenWeatherDailyForecast?]()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.managedObjectContext!
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Change background color
        self.view.backgroundColor = MobileConfig.sharedManager().backgroundCol
        
        // Resize tempLabel font based on the UILabel's width
        self.tempLabel.adjustsFontSizeToFitWidth = true
        
        // fetch records from Core Data
        self.fetchCurrentWeather()
        self.fetchDailyForecast()
        
        // determine class type of this controller's navController
        if let navController = self.navigationController where navController.isKindOfClass(OWMNavigationController) {
            // add bar button item to nav bar for the hamburger icon
            let hamburger = UIBarButtonItem(image: UIImage(named: "hamburger_icon.png"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(OWMViewController.leftBarButton(_:)))
            self.navigationItem.leftBarButtonItem = hamburger
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
// MARK: CORE DATA
    func fetchCurrentWeather() {
        
        // fetch OpenWeather records from core data
        let currentWeatherRequest = NSFetchRequest(entityName: "OpenWeather")
//        currentWeatherRequest.sortDescriptors = [NSSortDescriptor(key: "lastUpdated", ascending: false)]
        //fetchRequest.predicate = NSPredicate(format: "lastUpdated >= %@ AND lastUpdated <= %@", NSDate(timeIntervalSinceNow: -1200), NSDate(timeIntervalSinceNow: 0))
        
        do {
            // fetch records
            let records = try self.managedObjectContext.executeFetchRequest(currentWeatherRequest) as! [OpenWeather]
            
            if records.count > 0 {
                self.currentWeather = records.first!
                
                if let image = self.currentWeather.icon, temp = self.currentWeather.temp, description = self.currentWeather.main {
                    self.weatherIcon.image = UIImage(named: image)
                    self.tempLabel.text = temp
                    self.descriptionLabel.text = description
                }
                
                if let humidity = self.currentWeather.humidity {
                    self.humidityLabel.text = humidity + "%"
                }
                
                if let sunrise = self.currentWeather.sunrise {
                    self.sunriseLabel.text = sunrise + "am"
                }
                
                if let sunset = self.currentWeather.sunset {
                    self.sunsetLabel.text = sunset + "pm"
                }
                
                if let clouds = self.currentWeather.cloudPerc {
                    self.cloudPercentageLabel.text = clouds + "%"
                }
                
                if let pressure = self.currentWeather.pressure {
                    self.pressureLabel.text = pressure + "hPa"
                }
                
                if let wind = self.currentWeather.windSpeed {
                    self.windSpeedLabel.text = wind + "mph"
                }
                
                if let retrieve = self.currentWeather.retrieveTime {
                    self.lastUpdatedLabel.text = self.lastUpdatedLabel.text! + retrieve
                }
                
                if let low = self.currentWeather.minTemp, high = self.currentWeather.maxTemp {
                    self.highLowLabel.text = low + " / " + high + " " + OpenWeather.degreeF
                }
                
                
            }
            
            
        } catch let error as NSError {
            print("Error fetching OpenWeather data in \(#function): \(error)")
        }
        
        
    }
    
    func fetchDailyForecast() {
        
        let dailyForecastRequest = NSFetchRequest(entityName: "OpenWeatherDailyForecast")
        dailyForecastRequest.fetchBatchSize = 5
        dailyForecastRequest.sortDescriptors = [NSSortDescriptor(key: "day", ascending: true)]
        //dailyForecastRequest.predicate = NSPredicate(format: "day > %lf", self.currentWeather.dt)
        
        do {
            // fetch records
            let records = try self.managedObjectContext.executeFetchRequest(dailyForecastRequest) as! [OpenWeatherDailyForecast]
            
//            if records.count == 5 {
//                self.dailyForecast = records.map({ $0 as OpenWeatherDailyForecast })
//            }
            
            self.dailyForecast = records.map({ $0 as OpenWeatherDailyForecast })
            
        } catch let error as NSError {
            print("Error fetching OpenWeather data from CoreData: %@", error.localizedDescription)
        }
        
    }

    
    @IBAction func rightBarButton(sender: AnyObject) {
        self.viewDeckController.toggleRightView()
    }
    
    func leftBarButton(sender: AnyObject) {
        self.viewDeckController.toggleLeftView()
    }
    
    
    
    
// MARK: UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dailyForecast.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        // dequeue a reusable cell for the collection view
        let cell = self.forecastCollection.dequeueReusableCellWithReuseIdentifier("forecastCell", forIndexPath: indexPath) as! OWMForecastCollectionViewCell
        
        // retrieve the corresponding forecast data
        if let day = self.dailyForecast[indexPath.item] {
            
            if let icon = day.icon {
                cell.iconImage.image = UIImage(named: icon)
            }
            
            if let description = day.main {
                cell.weatherDescriptionLabel.text = description
            }

            if let min = day.minTemp, max = day.maxTemp {
                cell.highLowTempLabel.text = min + " / " + max + OpenWeather.degreeF
            }
            
            if let weekday = day.weekday {
                cell.weekdayLabel.text = weekday
            }
            
            
            // get formatted date
            let date = NSDate(timeIntervalSince1970: day.day)
            let formatter = NSDateFormatter()
            formatter.dateFormat = "MM/d"
            
            cell.dateLabel.text = formatter.stringFromDate(date)
            
        }
        
        return cell
    }
    
    
// MARK: UICollectionViewDelegate
//    func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
//        return true
//    }
    
//    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
//        
//        // extract the selected day's corresponding object
//        self.selectedForecastDay = self.dailyForecast[indexPath.item]
//        
//        // segue
//        self.performSegueWithIdentifier("showHourlyForecast", sender: self)
//        
//    }


// MARK: UICollectionViewDelegateFlowLayout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    
        return CGSizeMake(self.forecastCollection.frame.size.height * 0.6, self.forecastCollection.frame.size.height)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showHourlyForecast" {
            
            // get the indexpath for the selected cell
            if let indexPath = self.forecastCollection.indexPathForCell(sender as! OWMForecastCollectionViewCell) {
                
                let dest = segue.destinationViewController as! HourlyForecastTableViewController
                
                if let day = self.dailyForecast[indexPath.item] {
                    dest.forecastForDay = day
                }
                
            }
        
        }
        
    }
    

}
