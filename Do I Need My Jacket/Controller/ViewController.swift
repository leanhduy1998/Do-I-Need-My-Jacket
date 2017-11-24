//
//  ViewController.swift
//  Do I Need My Jacket
//
//  Created by Duy Le on 11/20/17.
//  Copyright © 2017 Duy Le. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var imageview: UIImageView!
    
    
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherStatusLabel: UILabel!
    @IBOutlet weak var remindLabel: UILabel!
    @IBOutlet weak var minMaxLabel: UILabel!
    @IBOutlet weak var swipeLabel: UILabel!
    
    var blurEffectView = UIVisualEffectView()
    
    
    var authStatus = CLLocationManager.authorizationStatus()
    var inUse = CLAuthorizationStatus.authorizedWhenInUse
    var always = CLAuthorizationStatus.authorizedAlways
    
    private let textBringYourJacketAndUmbrella = "Bring Your Jacket And Umbrella!"
    private let textBringYourJacket = "Bring Your Jacket"
    private let textBringYourUmbrella = "Bring Your Umbrella"
    private let textYouDontHaveToCarryYourJacket = "You Don't Have to Carry Your Jacket"
    
    
    var isC = true
    var minTemp:Double!
    var maxTemp:Double!
    var currentTemp:Double!
    
    var preferedTemp: Double!
    
    let formatter = NumberFormatter()
    
    let stack = CoreDataStack(modelName: "UserModel")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "UserData")
        fr.sortDescriptors = [NSSortDescriptor(key: "isC", ascending: true),
                              NSSortDescriptor(key: "preferedTemp", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
        
        let fetchedObjects = fetchedResultsController.fetchedObjects as? [UserData]
        
        if fetchedObjects?.count == 0 {
            let alertController = UIAlertController(title: "What Temperature Do You Think You Don't Have To Wear a Jacket?", message: "", preferredStyle: .alert)
            
            let saveAction = UIAlertAction(title: "Save", style: .default, handler: {
                alert -> Void in
                
                let firstTextField = alertController.textFields![0] as UITextField
                let secondTextField = alertController.textFields![1] as UITextField
                
                let temperatureText = firstTextField.text
                let typeText = secondTextField.text
                
                if Int(temperatureText!) == nil || (typeText != "F" && typeText != "C" && typeText != "f" && typeText != "c") {
                    firstTextField.text = ""
                    secondTextField.text = ""
                    self.present(alertController, animated: true, completion: nil)
                }
                else{
                    self.preferedTemp = Double(Int(temperatureText!)!)
                    if typeText == "F" || typeText == "f"{
                        DispatchQueue.main.async {
                            self.isC = false
                            
                            let _ = UserData(isC: false, preferedTemp: Double(Int(temperatureText!)!), context: self.stack.context)
                            do{
                                try self.stack.saveContext()
                            }
                            catch {
                                
                            }
                            self.setupLocation()
                        }
                    }
                    else{
                        DispatchQueue.main.async {
                            self.isC = true
                            let _ = UserData(isC: true, preferedTemp: Double(Int(temperatureText!)!), context: self.stack.context)
                            do{
                                try self.stack.saveContext()
                            }
                            catch {
                                
                            }
                            self.setupLocation()
                        }
                    }
                }
            })
            alertController.addAction(saveAction)
            
            alertController.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = "Enter Your Temperature"
            }
            alertController.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = "Enter F or C (Fahrenheit or Celsius)"
            }
            
            self.present(alertController, animated: true, completion: nil)
        }
        else{
            isC = fetchedObjects![0].isC
            preferedTemp = fetchedObjects![0].preferedTemp
            setupLocation()
        }
        
        formatter.maximumFractionDigits = 1
        setupUI()
        
        
    }
    
    func setupLocation(){
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            
            authStatus = CLLocationManager.authorizationStatus()
            inUse = CLAuthorizationStatus.authorizedWhenInUse
            always = CLAuthorizationStatus.authorizedAlways
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        getLocation { (info, error) in
            if error == nil {
                guard let city = info["City"] as? String else {
                    return
                }
                DispatchQueue.main.async {
                    FlickrClient.downloadLocationImagesUrls(cityName: city, completeHandler: { (urls, error) in
                        if error == nil || error.isEmpty {
                            let random = Int(arc4random_uniform(UInt32(urls.count)))
                            DispatchQueue.main.async {
                                self.loadUIFromJSON(url: urls[random], city: city)
                            }
                        }
                    })
                }
            }
        }
    }
    
    func loadUIFromJSON(url: String, city: String){
        URLSession.shared.dataTask(with: NSURL(string: url)! as URL, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                print(error)
                return
            }
            DispatchQueue.main.async(execute: { () -> Void in
                let image = UIImage(data: data!)
                self.imageview.image = image
                
                //     let locValue:CLLocationCoordinate2D = manager.location!.coordinate
                //   print("locations = \(locValue.latitude) \(locValue.longitude)")
                self.loadUIFromWeatherJSON(city: city)
                
            })
        }).resume()
    }
    
    func loadUIFromWeatherJSON(city: String){
        OpenWeatherAppClient.getCurrentWeather( cityName: city, completeHandler: { (weatherDic, error) in
            if !error.isEmpty {
                return
            }
            DispatchQueue.main.async {
                var min = (weatherDic["main"] as! [String:Any])["temp_min"]! as! Double
                var max = (weatherDic["main"] as! [String:Any])["temp_max"]! as! Double
                var current = (weatherDic["main"] as! [String:Any])["temp"]! as! Double
                
                if self.isC {
                    min = min - 273.15
                    max = max - 273.15
                    current = current - 273.15
                    
                    self.minTemp = min
                    self.maxTemp = max
                    self.currentTemp = current
                        
                    self.minMaxLabel.text = "Min: \(self.formatter.string(for: min)!)°C, Max: \(self.formatter.string(for: max)!)°C"
                    self.temperatureLabel.text = "\(self.formatter.string(for: current)!)°C"
      
                    if let weather = weatherDic["weather"] as? [[String:Any]], !weather.isEmpty {
                        var status = weather[0]["description"]! as! String
                        status = status.uppercased()
                        
                        self.weatherStatusLabel.text = status
                        if status.lowercased().range(of:"rain") != nil {
                            if self.currentTemp < self.preferedTemp  {
                                self.remindLabel.text = self.textBringYourJacketAndUmbrella
                            }
                            else {
                                self.remindLabel.text = self.textBringYourUmbrella
                            }
                        }
                        else{
                            if self.currentTemp < self.preferedTemp  {
                                self.remindLabel.text = self.textBringYourJacket
                            }
                            else {
                                self.remindLabel.text = self.textYouDontHaveToCarryYourJacket
                            }
                        }
                    }
                }
                else{
                    min = 9/5*(min-273) + 32
                    max = 9/5*(max-273) + 32
                    current = 9/5*(current-273) + 32
                    
                    self.minTemp = min
                    self.maxTemp = max
                    self.currentTemp = current
                    
                    self.minMaxLabel.text = "Min: \(self.formatter.string(for: min)!)°F, Max: \(self.formatter.string(for: max)!)°F"
                    self.temperatureLabel.text = "\(self.formatter.string(for: current)!)°F"
                    
                    if let weather = weatherDic["weather"] as? [[String:Any]], !weather.isEmpty {
                        var status = weather[0]["description"]! as! String
                        status = status.uppercased()
                        
                        self.weatherStatusLabel.text = status
                        if status.lowercased().range(of:"rain") != nil {
                            if self.currentTemp < self.preferedTemp  {
                                self.remindLabel.text = self.textBringYourJacketAndUmbrella
                            }
                            else {
                                self.remindLabel.text = self.textBringYourUmbrella
                            }
                        }
                        else{
                            if self.currentTemp < self.preferedTemp  {
                                self.remindLabel.text = self.textBringYourJacket
                            }
                            else {
                                self.remindLabel.text = self.textYouDontHaveToCarryYourJacket
                            }
                        }
                    }
                }
            }
        })
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func getLocation(completion: @escaping (_ address: [String:Any], _ error: Error?) -> ()){
        locationManager.requestWhenInUseAuthorization()
        
        if authStatus == inUse || authStatus == always {
            currentLocation = locationManager.location
            
            let geoCoder = CLGeocoder()
            
            geoCoder.reverseGeocodeLocation(currentLocation) { placemarks, error in
                
                if let e = error {
                    completion([:], e)
                    
                } else {
                    let placeArray = placemarks
                    var placeMark: CLPlacemark!
                
                    placeMark = placeArray?[0]
                    guard let address = placeMark.addressDictionary as? [String:Any] else {
                        return
                    }
                    completion(address, nil)
                }
            }
        }
    }

  
}

