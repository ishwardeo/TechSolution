//
//  Utilities.swift
//  UsersList
//
//  Created by Mac on 28/07/20.
//  Copyright © 2020 TechSolution. All rights reserved.
//

import Foundation

struct Utilities {
    static func filterAge(userList list: [User]) -> [User] {
        let filterNilAgeList = list.filter { (user: User) -> Bool in
            let age = user.age
            if age > 0 {
                return true
            }
            return false
        }
        return filterNilAgeList
    }
    
    static func filterGender(userList list: [User], filterText excludeText: FilterOptions) -> [User] {
        var filterNilAgeList = list
        switch excludeText {
            case FilterOptions.male:
                filterNilAgeList = list.filter { (user: User) -> Bool in
                let gender = user.gender
                    if gender == FilterOptions.male.rawValue {
                        return true
                    }
                    return false
                }
            default:
                filterNilAgeList = list.filter { (user: User) -> Bool in
                let gender = user.gender
                    if gender == FilterOptions.female.rawValue {
                        return true
                    }
                    return false
                }
        }
        return filterNilAgeList
    }

    
    static func sortedList(userList list: [User], sortOrder order: SortOptions) -> [User] {
        var sortedList = list
        
        switch order {
        case SortOptions.descending:
                sortedList = list.sorted { (user1: User, user2: User) -> Bool in
                    return user1.age >= user2.age
                }

            default:
                sortedList = list.sorted { (user1: User, user2: User) -> Bool in
                    return user1.age <= user2.age
                }
        }
        return sortedList
    }
}
