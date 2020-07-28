//
//  UserListViewModel.swift
//  UsersList
//
//  Created by Mac on 28/07/20.
//  Copyright © 2020 TechSolution. All rights reserved.
//

import UIKit
import CoreData

let appDelegate = UIApplication.shared.delegate as! AppDelegate

class UserListViewModel {
    
    ///closure for communication between View Model & Controller
    var reloadList = {() -> () in }
    var errorMessage = {(message : String) -> () in }
    
    var sourceList: [User] = [] // Origional list without any filter, without any sorting
    
    ///Array of List Model class
    var arrayOfList : [User] = [] {
        ///Reload data when data set
        didSet{
            reloadList()
        }
    }
    
    /// Download image
    func downloadImage(urlString: String?, completion: @escaping (UIImage?) -> Void)  {
        guard let tempURLstring = urlString else {
            completion(nil)
            return
        }
        guard let listURL = URL(string: tempURLstring) else {
            return
        }
        URLSession.shared.dataTask(with: listURL) {
            (data,response,error) in
            guard let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            completion(image)
        }.resume()
    }
    
    ///get data from api
    func getListData()  {
        guard let listURL = URL(string: "https://5f11524e65dd950016fbd329.mockapi.io/user")else {
            return
        }
        URLSession.shared.dataTask(with: listURL){
            (data,response,error) in
            guard let jsonData = data else { return }
            DispatchQueue.main.async {
                self.parseResponse(forData: jsonData)
            }
        }.resume()
    }
    
    ///parse response using decodable and store data
    func parseResponse(forData jsonData : Data)  {
        do {
            guard let codableContext = CodingUserInfoKey.init(rawValue: "context") else {
                fatalError("Failed context")
            }
            
            let manageObjContext = appDelegate.persistentContainer.viewContext
            let decoder = JSONDecoder()
            decoder.userInfo[codableContext] = manageObjContext
            // Parse JSON data
            let decodedJSON = try decoder.decode([User].self, from: jsonData)
            print("\n ********  decodedJSON :  *******\n \(decodedJSON)")
            ///context save
            try manageObjContext.save()
            UserDefaults.standard.set(true, forKey: GlobalConstants.DATA_ALREADY_DOWNLOADED)
            
            self.fetchLocalData()
        } catch let error {
            print("Error ->\(error.localizedDescription)")
            self.errorMessage(error.localizedDescription)
        }
    }
    
    ///Local data fetch from core data
    func fetchLocalData()  {
        let manageObjContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<User>(entityName: "User")
        ///Sort by id
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            // No further modification
            let tempSourceList = try manageObjContext.fetch(fetchRequest)

            let listWithoutAgeZero = Utilities.filterAge(userList: tempSourceList)
            let sortedListByAge = Utilities.sortedList(userList: listWithoutAgeZero, sortOrder: SortOptions.ascending)
            sourceList = sortedListByAge
            
            // Initially show sourceList
            arrayOfList = sourceList
        } catch let error {
            print(error)
            self.errorMessage(error.localizedDescription)
        }
    }
    
    /// Delete all the objects
    func deleteAll() {
        do {
            let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
            let deleteAllRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
            
            let managedContext = appDelegate.persistentContainer.viewContext
            try managedContext.execute(deleteAllRequest)
            UserDefaults.standard.set(false, forKey: GlobalConstants.DATA_ALREADY_DOWNLOADED)
        } catch {
            let error = error as NSError
            print("Error", error.localizedDescription)
        }
    }
    
    /// Filter based on male/female
    func filterGender(filterText excludeText: FilterOptions) {
        let filteredList = Utilities.filterGender(userList: sourceList, filterText: excludeText)
        arrayOfList = filteredList
    }
    
    /// sort based on ascending/descending
    func sortInOrder(sortOrder order: SortOptions) {
        let sortedList = Utilities.sortedList(userList: sourceList, sortOrder: order)
        arrayOfList = sortedList
    }
}


