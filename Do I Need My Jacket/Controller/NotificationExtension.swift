//
//  NotificationExtension.swift
//  Do I Need My Jacket
//
//  Created by Duy Le on 11/24/17.
//  Copyright © 2017 Duy Le. All rights reserved.
//

import Foundation
import UserNotifications

extension ViewController{
    func setupNotification(){
        let center = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .sound]
        
        center.requestAuthorization(options: options) {
            (granted, error) in
            if !granted {
                print("Something went wrong")
            }
        }
        
        center.getNotificationSettings { (settings) in
            if settings.authorizationStatus != .authorized {
                // Notifications not allowed
            }
        }
        
        let content = UNMutableNotificationContent()
        content.title = remindLabel.text!
        if isC{
            content.body = "Today Temperature is \(currentTemp!)°C, \(weatherStatusLabel.text!)"
        }
        else{
            content.body = "Today Temperature is \(currentTemp!)°F, \(weatherStatusLabel.text!)"
        }
        
        content.sound = UNNotificationSound.default()
        
        let gregorian = Calendar(identifier: .gregorian)
        var components = gregorian.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
        
        components.hour = 8
        components.minute = 0
        components.second = 0
        
        let date = gregorian.date(from: components)!
        
        let triggerDaily = Calendar.current.dateComponents([.hour,.minute,.second,], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDaily, repeats: true)
        
        
        let identifier = "UYLLocalNotification"
        let request = UNNotificationRequest(identifier: identifier,
                                            content: content, trigger: trigger)
        center.add(request, withCompletionHandler: { (error) in
            if let error = error {
                print(error)
            }
        })
    }
}
