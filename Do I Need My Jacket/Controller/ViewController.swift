//
//  ViewController.swift
//  Do I Need My Jacket
//
//  Created by Duy Le on 11/20/17.
//  Copyright © 2017 Duy Le. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var imageview: UIImageView!
    
    
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    var authStatus = CLLocationManager.authorizationStatus()
    var inUse = CLAuthorizationStatus.authorizedWhenInUse
    var always = CLAuthorizationStatus.authorizedAlways
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        // Ask for Authorisation from the User.
        locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
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
       // let locValue:CLLocationCoordinate2D = manager.location!.coordinate
      //  print("locations = \(locValue.latitude) \(locValue.longitude)")
        
        getLocation { (info, error) in
            if error == nil {
                guard let city = info["City"] as? String else {
                    return
                }
                DispatchQueue.main.async {
                    FlickrClient.downloadLocationImagesUrls(cityName: city, completeHandler: { (urls, error) in
                        if error == nil || error.isEmpty {
                            let random = Int(arc4random_uniform(10))
                            
                            URLSession.shared.dataTask(with: NSURL(string: urls[random])! as URL, completionHandler: { (data, response, error) -> Void in
                                if error != nil {
                                    print(error)
                                    return
                                }
                                DispatchQueue.main.async(execute: { () -> Void in
                                    let image = UIImage(data: data!)
                                    self.imageview.image = image
                                })
                            }).resume()
                        }
                    })
                }
            }
        }
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

