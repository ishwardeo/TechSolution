//
//  User+CoreDataClass.swift
//  UsersList
//
//  Created by Mac on 28/07/20.
//  Copyright © 2020 TechSolution. All rights reserved.
//

import Foundation
import CoreData

@objc(User)
public class User: NSManagedObject,Codable {
    
    ///From api response key if changed
    enum apiKey: String, CodingKey {
        case id
        case name
        case gender
        case age
        case avatar
    }

    // MARK: - Decodable
    required convenience public init(from decoder: Decoder) throws {
        
        ///Fetch context for codable
        guard let codableContext = CodingUserInfoKey.init(rawValue: "context"),
            let manageObjContext = decoder.userInfo[codableContext] as? NSManagedObjectContext,
            let manageObjList = NSEntityDescription.entity(forEntityName: "User", in: manageObjContext) else {
                fatalError("failed")
        }
        
        self.init(entity: manageObjList, insertInto: manageObjContext)
        
        let container = try decoder.container(keyedBy: apiKey.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.gender = try container.decodeIfPresent(String.self, forKey: .gender)
        self.age = try container.decodeIfPresent(Int64.self, forKey: .age) ?? 0
        self.avatar = try container.decodeIfPresent(String.self, forKey: .avatar)
    }
    
    // MARK: - encode
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: apiKey.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(gender, forKey: .gender)
        try container.encode(age, forKey: .age)
        try container.encode(avatar, forKey: .avatar)
    }
}
