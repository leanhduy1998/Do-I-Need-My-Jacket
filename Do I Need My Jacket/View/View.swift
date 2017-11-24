//
//  View.swift
//  Do I Need My Jacket
//
//  Created by Duy Le on 11/23/17.
//  Copyright © 2017 Duy Le. All rights reserved.
//

import Foundation
import UIKit

extension ViewController {
    func setupUI(){
        temperatureLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 100)
        weatherStatusLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 30)
        minMaxLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 30)
        remindLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 45)
        swipeLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 20)
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.regular)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.alpha = 0.5
        view.addSubview(blurEffectView)
        
        view.bringSubview(toFront: temperatureLabel)
        view.bringSubview(toFront: weatherStatusLabel)
        view.bringSubview(toFront: minMaxLabel)
        view.bringSubview(toFront: remindLabel)
        view.bringSubview(toFront: swipeLabel)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeUp.direction = UISwipeGestureRecognizerDirection.up
        self.view.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeDown.direction = UISwipeGestureRecognizerDirection.down
        self.view.addGestureRecognizer(swipeDown)
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if isC {
            isC = !isC
            minTemp = minTemp * 9 / 5 + 32
            maxTemp = maxTemp * 9 / 5 + 32
            currentTemp = currentTemp * 9 / 5 + 32
            
            minMaxLabel.text = "Min: \(formatter.string(for: minTemp)!)°F, Max: \(formatter.string(for: maxTemp)!)°F"
            temperatureLabel.text = "\(formatter.string(for: currentTemp)!)°F"
            
            UIView.animate(withDuration: 0.25, animations: {
                self.blurEffectView.alpha = 1
            }, completion: { (completed) in
                if completed {
                    UIView.animate(withDuration: 0.25, animations: {
                        self.blurEffectView.alpha = 0.5
                    })
                }
            })
            swipeLabel.text = "Swipe to change to Celsius"
        }
        else {
            isC = !isC
            minTemp = (minTemp - 32) * 5 / 9
            maxTemp = (maxTemp - 32) * 5 / 9
            currentTemp = (currentTemp - 32) * 5 / 9
            
            minMaxLabel.text = "Min: \(formatter.string(for: minTemp)!)°C, Max: \(formatter.string(for: maxTemp)!)°C"
            temperatureLabel.text = "\(formatter.string(for: currentTemp)!)°C"
            
            UIView.animate(withDuration: 0.25, animations: {
                self.blurEffectView.alpha = 1
            }, completion: { (completed) in
                if completed {
                    UIView.animate(withDuration: 0.25, animations: {
                        self.blurEffectView.alpha = 0.5
                    })
                }
            })
            
            swipeLabel.text = "Swipe to change to Fahrenheit"
        }
    }
}
