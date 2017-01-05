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
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor(red: 51.0/255.0, green: 51.0/255.0, blue: 51.0/255.0, alpha: 1.0)
        
        // Resize tempLabel font based on the UILabel's width
        self.tempLabel.adjustsFontSizeToFitWidth = true
        
        // fetch records from Core Data
        self.fetchCurrentWeather()
        self.fetchDailyForecast()
        
    }
    
    
// MARK: CORE DATA
    func fetchCurrentWeather() {
        
        let currentWeatherRequest = NSFetchRequest(entityName: "OpenWeather")
        
        do {
            // fetch records
            let records = try self.managedObjectContext.executeFetchRequest(currentWeatherRequest) as! [OpenWeather]
            
            if records.count > 0 {
                self.currentWeather = records.first!
                
                if let image = self.currentWeather.icon, let temp = self.currentWeather.temp, let description = self.currentWeather.main {
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
                
                if let low = self.currentWeather.minTemp, let high = self.currentWeather.maxTemp {
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
            
            self.dailyForecast = records.map({ $0 as OpenWeatherDailyForecast })
            
        } catch let error as NSError {
            print("Error fetching OpenWeather data from CoreData: %@", error.localizedDescription)
        }
        
    }
    
    
    
// MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dailyForecast.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // dequeue a reusable cell for the collection view
        let cell = self.forecastCollection.dequeueReusableCell(withReuseIdentifier: "forecastCell", for: indexPath) as! OWMForecastCollectionViewCell
        
        // retrieve the corresponding forecast data
        if let day = self.dailyForecast[indexPath.item] {
            
            if let icon = day.icon {
                cell.iconImage.image = UIImage(named: icon)
            }
            
            if let description = day.main {
                cell.weatherDescriptionLabel.text = description
            }

            if let min = day.minTemp, let max = day.maxTemp {
                cell.highLowTempLabel.text = min + " / " + max + OpenWeather.degreeF
            }
            
            if let weekday = day.weekday {
                cell.weekdayLabel.text = weekday
            }
            
            
            // get formatted date
            let date = Date(timeIntervalSince1970: day.day)
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/d"
            
            cell.dateLabel.text = formatter.string(from: date)
            
        }
        
        return cell
    }


// MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.forecastCollection.frame.size.height * 0.6, height: self.forecastCollection.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showHourlyForecast" {
            
            // get the indexpath for the selected cell
            if let indexPath = self.forecastCollection.indexPath(for: sender as! OWMForecastCollectionViewCell) {
                
                let dest = segue.destination as! HourlyForecastTableViewController
                
                if let day = self.dailyForecast[indexPath.item] {
                    dest.forecastForDay = day
                }
                
            }
        
        }
        
    }
    

}
