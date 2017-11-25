//
//  WeatherAPIExtension.swift
//  Do I Need My Jacket
//
//  Created by Duy Le on 11/24/17.
//  Copyright © 2017 Duy Le. All rights reserved.
//

import Foundation
import UIKit

extension ViewController{
    func loadUIFromJSON(url: String, city: String, completeHandler: @escaping ( ) -> Void){
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
                self.loadUIFromWeatherJSON(city: city, completeHandler: completeHandler)
                
            })
        }).resume()
    }
    
    func loadUIFromWeatherJSON(city: String,completeHandler: @escaping ( ) -> Void){
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
                completeHandler()
            }
        })
    }
}
