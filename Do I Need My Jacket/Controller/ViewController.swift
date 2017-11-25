//
//  ViewController.swift
//  Do I Need My Jacket
//
//  Created by Duy Le on 11/20/17.
//  Copyright © 2017 Duy Le. All rights reserved.
//

import UIKit
import MapKit
import UserNotifications

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
    
    let textBringYourJacketAndUmbrella = "Bring Your Jacket And Umbrella!"
    let textBringYourJacket = "Bring Your Jacket"
    let textBringYourUmbrella = "Bring Your Umbrella"
    let textYouDontHaveToCarryYourJacket = "You Don't Have to Carry Your Jacket"
    
    
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
        formatter.maximumFractionDigits = 1
        setupUI()
        loadUserDataFromMemoryAndSetupUI()
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
                                self.loadUIFromJSON(url: urls[random], city: city, completeHandler: {
                                    self.setupNotification()
                                    
                                })
                            }
                        }
                    })
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

