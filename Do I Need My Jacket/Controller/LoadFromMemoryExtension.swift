//
//  LoadFromMemoryExtension.swift
//  Do I Need My Jacket
//
//  Created by Duy Le on 11/24/17.
//  Copyright © 2017 Duy Le. All rights reserved.
//

import Foundation
import CoreData
import UIKit

extension ViewController{
    func loadUserDataFromMemoryAndSetupUI(){
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
    }
}
