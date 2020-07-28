//
//  User+CoreDataProperties.swift
//  UsersList
//
//  Created by Mac on 28/07/20.
//  Copyright © 2020 TechSolution. All rights reserved.
//

import Foundation
import CoreData

extension User {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var name: String?
    @NSManaged public var id: String?
    @NSManaged public var gender: String?
    @NSManaged public var avatar: String?
    @NSManaged public var age: Int64
}
