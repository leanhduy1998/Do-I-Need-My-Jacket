//
//  UserData+CoreDataProperties.swift
//  Do I Need My Jacket
//
//  Created by Duy Le on 11/23/17.
//  Copyright © 2017 Duy Le. All rights reserved.
//
//

import Foundation
import CoreData


extension UserData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserData> {
        return NSFetchRequest<UserData>(entityName: "UserData")
    }

    @NSManaged public var isC: Bool
    @NSManaged public var preferedTemp: Double

}
