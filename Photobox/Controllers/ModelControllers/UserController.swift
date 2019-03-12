//
//  UserController.swift
//  Photobox
//
//  Created by Nathan Andrus on 3/11/19.
//  Copyright © 2019 Nathan Andrus. All rights reserved.
//

import UIKit
import CloudKit
import Contacts

class UserController {
    
    static let shared = UserController()
    
    var loggedInUser: User?
    var users: [User] = []
    
    func saveUserWith(username: String, profilePic: UIImage, completion: @escaping (Bool) -> Void) {
        CKContainer.default().fetchUserRecordID { (appleUserRecordID, error) in
            if let error = error {
                print("Error fetching user's apple ID: \(error.localizedDescription)")
                completion(false)
                return
            }
            guard let appleUserRecordID = appleUserRecordID else { completion(false); return }
            
            let reference = CKRecord.Reference(recordID: appleUserRecordID, action: .deleteSelf)
            
            let newUser = User(username: username, profileImage: profilePic, ckRecord: appleUserRecordID, creatorReference: reference)
            
            let record = CKRecord(user: newUser)
            
            guard let newRecord = record else { completion(false); return }
            
            CloudKitManager.shared.saveRecord(newRecord, completion: { (record, error) in
                if let error = error {
                    print("Error saving record to CK: \(error), \(error.localizedDescription)")
                    return
                }
                
                guard let record = record else { return }
                let user = User(record: record)
                self.loggedInUser = user
            })
        }
    }
    
    func fetchLoggedInUser(completion: @escaping (Bool) -> Void) {
        CloudKitManager.shared.fetchLoggedInUserRecord { (userRecord, error) in
            if let error = error {
                print("Error fetching logged in user: \(error), \(error.localizedDescription)")
                return
            }
            
            guard let userRecord = userRecord else { return }
            
            let user = User(record: userRecord)
            
            self.loggedInUser = user
        }
    }
    
    func fetchAllUsers(completion: @escaping (Bool) -> Void) {
        
        let predicate = NSPredicate(value: true)
        
        let query = CKQuery(recordType: User.typeKey, predicate: predicate)
        
        CKContainer.default().publicCloudDatabase.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
            if let error = error {
                print("Error finding user ref: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard let records = records else { return }
            
            for record in records {
                let newUser = User(record: record)
                guard let user = newUser else { return }
                self.users.append(user)
            }
            completion(true)
        })
    }

}

