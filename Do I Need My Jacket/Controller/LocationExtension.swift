//
//  LocationExtension.swift
//  Do I Need My Jacket
//
//  Created by Duy Le on 11/24/17.
//  Copyright © 2017 Duy Le. All rights reserved.
//

import Foundation
import MapKit

extension ViewController{
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
}
