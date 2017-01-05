//
//  WeatherFetcher.swift
//  GoMizzou
//
//  Created by Josh O'Steen on 10/12/15.
//  Copyright © 2015 University of Missouri. All rights reserved.
//

import UIKit
import Foundation
import CoreData

// Structure defining the information about a city. The default
// values are for Columbia, MO but mutating functions are implemented
// to change these values after instantiation along with an init()
// method for instantiating a custom city struct.
struct City {
    private(set) var id : Int
    private(set) var name : String
    private(set) var county : String
    private(set) var country : String
    private(set) var lat : Double
    private(set) var lon : Double
    
    init() {
        self.id = 4381982
        self.name = "Columbia"
        self.county = "Boone"
        self.country = "United States"
        self.lat = 38.95171
        self.lon = -92.334068
    }
    
    init(withID id: Int, name: String, county: String, country: String, withCoordinates coords: (lat: Double, lon: Double)) {
        self.id = id
        self.name = name
        self.county = county
        self.country = country
        self.lat = coords.lat
        self.lon = coords.lon
    }
    
    mutating func setID(toID id: Int) {
        self.id = id
    }
    
    mutating func setName(toName name: String) {
        self.name = name
    }
    
    mutating func setCounty(toCounty county: String) {
        self.county = county
    }
    
    mutating func setCountry(toCountry country: String) {
        self.country = country
    }
    
    mutating func setCoords(toLatAndLon coords: (lat: Double, lon: Double)) {
        self.lat = coords.lat
        self.lon = coords.lon
    }
}


enum WeatherType: String {
    case Current = "http://api.openweathermap.org/data/2.5/weather?"
    case Hourly = "http://api.openweathermap.org/data/2.5/forecast?"
    case Daily = "http://api.openweathermap.org/data/2.5/forecast/daily?"
    case History = "http://api.openweathermap.org/data/2.5/history/city?"
}


@objc class WeatherFetcher: NSObject {
    
    private let APPID = "30c51256fa77a35b476cf6cf82a2f779"
    
    private var currentWeather : OpenWeather!
    
    lazy var context : NSManagedObjectContext = {
        return self.delegate.persistentContainer.viewContext
    }()
    
    lazy var delegate : AppDelegate = {
       return UIApplication.shared.delegate as! AppDelegate
    }()
    
    // Singleton
    static let sharedFetcher = WeatherFetcher()
    private override init() {
        super.init()
    }
    
    // Kickoff the update process
    @objc func updateAllOpenWeatherServices() {
        print("*** UPDATING OPEN WEATHER ***")
        self.getCurrentWeather()
//        self.getFiveDayForecastWeather()
//        self.getHourlyForecastWeather()
    }
    
    // Use these methods when calling from objc code since
    // WeatherType cannot be inferred from objc
    func getCurrentWeather() {

        // Define the city and weather type
        let city = City()
        let weatherType = WeatherType.Current
        
        // Create a string representation of our api URL
        let stringURL = weatherType.rawValue + "id=" + String(city.id) + "&units=imperial" + "&APPID=" + APPID
        
        // Create the URL from the string
        guard let url = URL(string: stringURL) else {
            print("NSURL could not be created for current weather request in \(#function)")
            return
        }
        
        let session = URLSession.shared
        
        let dataTask = session.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            // Check for errors
            if let error = error {
                print("Error fetching current weather data in \(#function): \(error)")
                return
            }
            
            // Check the response code
            if let res = response as! HTTPURLResponse? {
                if res.statusCode != 200 {
                    return
                }
            }
            
            // Process the data
            guard let data = data else { return }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] {
                    DispatchQueue.main.async {
                        self.processCurrentWeatherData(json: json)
                    }
                }
                
            } catch let error as NSError {
                print("Error deserializing open weather data in \(#function): \(error)")
            }
            
        }
        
        dataTask.resume()
        
        
    }
    
    
    func getFiveDayForecastWeather() {
        
        // Define the city and weather type
        let city = City()
        let weatherType = WeatherType.Daily
        
        // create a string representation of our api call URL including
        // city ID, units format (imperial), and API key
        let stringURL = weatherType.rawValue + "id=" + String(city.id) + "&units=imperial" + "&cnt=6" + "&APPID=" + APPID
        
        // Create the actual URL from the string
        guard let url = URL(string: stringURL) else {
            print("NSURL could not be created for forecast request in \(#function)")
            return
        }
        
        // create the request session
        let session = URLSession.shared
        
        let dataTask = session.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            // Check for errors
            if let error = error {
                print("Error fetching current weather data in \(#function): \(error)")
                return
            }
            
            // Check the response code
            if let res = response as! HTTPURLResponse? {
                if res.statusCode != 200 {
                    return
                }
            }
            
            // Process the data
            guard let data = data else { return }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] {
                    DispatchQueue.main.async {
                        self.processDailyForecastData(json: json)
                    }
                    
                }
            } catch let error as NSError {
                print("Error deserializing open weather data in \(#function): \(error)")
            }
            
        }
        
        dataTask.resume()
        
    }
    
    
    func getHourlyForecastWeather() {
        
        // Define the city and weather type
        let city = City()
        let weatherType = WeatherType.Hourly
        
        // create a string representation of our api call URL including
        // city ID, units format (imperial), and API key
        let stringURL = weatherType.rawValue + "id=" + String(city.id) + "&units=imperial" + "&APPID=" + APPID
        print(stringURL)
        
        // Create the actual URL from the string
        guard let url = URL(string: stringURL) else {
            print("NSURL could not be created for forecast request in \(#function)")
            return
        }
        
        // create the request session
        let session = URLSession.shared
        
        let dataTask = session.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            // Check for errors
            if let error = error {
                print("Error fetching current weather data in \(#function): \(error)")
                return
            }
            
            // Check the response code
            if let res = response as! HTTPURLResponse? {
                if res.statusCode != 200 {
                    return
                }
            }
            
            // Process the data
            guard let data = data else { return }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] {
                    DispatchQueue.main.async {
                        self.processHourlyWeatherData(json: json)
                    }
                    
                }
            } catch let error as NSError {
                print("Error deserializing open weather data in \(#function): \(error)")
            }
        }
        
        dataTask.resume()
        
    }

    
    func processCurrentWeatherData(json: [String : Any]) {
        
        if let currentWeather = OpenWeather(withJSON: json, inManagedObjectContext: self.context) {
            // Check if there are any existing entities in the persistent store
            let request = NSFetchRequest(entityName: "OpenWeather")
            do {
                let results = try self.context.executeFetchRequest(request) as! [OpenWeather]
                
                if !results.isEmpty {
                    self.deleteEntities(results, inManagedObjectContext: self.context)
                }
                
            } catch let error as NSError {
                print("Error fetching OpenWeather records in \(#function): \(error)")
            }
            
            
            self.context.insert(currentWeather)
            self.delegate.saveContext()
            
            self.currentWeather = currentWeather
            self.getFiveDayForecastWeather()
        }
        
    }
    
    
    func processDailyForecastData(json: [String : Any]) {
        
        if let list = json["list"] as? [[String : Any]]  {
            var dailyForecasts : [OpenWeatherDailyForecast] = []
            
            for index in 1...5 {
                let jsonForDay = list[index]
                
                if let day = OpenWeatherDailyForecast(withJSON: jsonForDay, inManagedObjectContext: self.context) {
                    dailyForecasts.append(day)
                }
                
            }
            
            if dailyForecasts.count != 5 {
                print("Unable to create 5 DailyForecast records")
                return
            }
            
            // Delete existing DailyForecast records
            let request = NSFetchRequest(entityName: "OpenWeatherDailyForecast")
            do {
                let results = try self.context.executeFetchRequest(request) as! [OpenWeatherDailyForecast]
                
                if !results.isEmpty {
                    self.deleteEntities(results, inManagedObjectContext: self.context)
                }
            } catch let error as NSError {
                print("Error fetching DailyForecast records in \(#function): \(error)")
            }
            
            for forecast in dailyForecasts {
                self.context.insert(forecast)
            }
            
            self.updateMinAndMaxTempForCurrentWeather(currentWeather: self.currentWeather, fromJSONData: list)
            
            self.delegate.saveContext()
            
            self.getHourlyForecastWeather()
        }
        
        
    }
    
    
    func processHourlyWeatherData(json: [String : Any]) {
        
        if let list = json["list"] as? [[String : Any]] {
            
            var hourlyForecasts : [OpenWeatherThreeHourForecast] = []
            
            for hourlyForecast in list {
                if let forecast = OpenWeatherThreeHourForecast(withJSON: hourlyForecast, inManagedObjectContext: self.context) {
                    hourlyForecasts.append(forecast)
                }
            }
            
            // Delete existing records before saving the new ones
            if !hourlyForecasts.isEmpty {
                let request = NSFetchRequest(entityName: "OpenWeatherThreeHourForecast")
                do {
                    let results = try self.context.executeFetchRequest(request) as! [OpenWeatherThreeHourForecast]
                    
                    if !results.isEmpty {
                        self.deleteEntities(results, inManagedObjectContext: self.context)
                    }
                } catch let error as NSError {
                    print("Error fetching HourlyForecast records in \(#function): \(error)")
                }
            } else {
                return
            }
            
            for forecast in hourlyForecasts {
                self.context.insert(forecast)
            }
            
            self.delegate.saveContext()
            
        }
        
    }
    
    
    func deleteEntities(entities: [NSManagedObject], inManagedObjectContext context: NSManagedObjectContext) {
        
        for entity in entities {
            context.delete(entity)
        }
        
        self.delegate.saveContext()
        
    }
    
    
    func updateMinAndMaxTempForCurrentWeather(currentWeather: OpenWeather?, fromJSONData json: [[String : Any]]) {
        
        if let currentWeather = currentWeather {
            
            guard let currentDay = json.first, let temp = currentDay["temp"] as? [String : Any] else { return }
            
            // Extract max/min temp from forecast
            if let min = temp["min"] as? Double, let max = temp["max"] as? Double {
                // Cast to Int then String before saving to record
                currentWeather.minTemp = String(Int(min))
                currentWeather.maxTemp = String(Int(max))
            }
        
        }
        
    }
    
    
    func fetchWeather(forCity city: City = City(), forType weatherType: WeatherType = WeatherType.Current, withCompletion completed: @escaping (_ jsonObject: Any?) -> (Any)) {
        
        // create a string representation of our api call URL
        let stringURL = weatherType.rawValue + "id=" + String(city.id)
        
        // create the actual URL from the string
        guard let url = URL(string: stringURL) else {
            print("NSURL could not be created")
            return
        }
        
        let session = URLSession.shared
        
        let dataTask = session.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            // unwrap and print the response
            if let res = response as! HTTPURLResponse? {
                print("Response: \(res.statusCode)")
            }
            
            // unwrap and print a string rep of the data
            if let dat = data {
                let dataString = NSString(data: dat, encoding: String.Encoding.utf8.rawValue)
                print("Body: \(dataString)")
                do {
                    let json = try JSONSerialization.jsonObject(with: dat, options: .mutableLeaves)
                    completed(json)
                } catch let error as NSError {
                    print(error)
                    let jsonStr = NSString(data: dat, encoding: String.Encoding.utf8.rawValue)
                    print(jsonStr ?? "")
                    completed(nil)
                } catch {
                    print("Failure creating weather JSON")
                    completed(nil)
                }
            }
            
        }
        
        dataTask.resume()
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
