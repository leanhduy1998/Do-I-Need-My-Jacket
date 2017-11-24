//
//  UserData+CoreDataClass.swift
//  Do I Need My Jacket
//
//  Created by Duy Le on 11/23/17.
//  Copyright © 2017 Duy Le. All rights reserved.
//
//

import Foundation
import CoreData

@objc(UserData)
public class UserData: NSManagedObject {
    convenience init(isC: Bool, preferedTemp: Double, context: NSManagedObjectContext){
        if let ent = NSEntityDescription.entity(forEntityName: "UserData", in: context){
            self.init(entity: ent, insertInto: context)
            self.isC = isC
            self.preferedTemp = preferedTemp
        }
        else {
            fatalError("unable to find Round Entity name")
        }
    }
}
