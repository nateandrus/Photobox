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

    // MARK: - Shared Instance/Singleton
    static let shared = UserController()
    
    //MARK: - Sources of Truth
    var loggedInUser: User?
    var events: [Event] = []
    var invitedEvents: [Event] = []
    var users: [User] = []
    
    //MARK: - CRUD Functions
    func saveUserWith(username: String, password: String, phoneNumber: String?, completion: @escaping (Bool) -> Void) {
        CKContainer.default().fetchUserRecordID { (appleUserRecordID, error) in
            if let error = error {
                print("Error fetching user's apple ID: \(error.localizedDescription)")
                completion(false)
                return
            }
            guard let appleUserRecordID = appleUserRecordID,
                let phoneNumber = phoneNumber else { completion(false); return }
            
            let reference = CKRecord.Reference(recordID: appleUserRecordID, action: .deleteSelf)
            
            let newUser = User(username: username, password: password, creatorReference: reference, phoneNumber: phoneNumber)
            
            guard let record = CKRecord(user: newUser) else
            { completion(false); return }
            
            CloudKitManager.shared.saveRecord(record, completion: { (record, error) in
                if let error = error {
                    print("Error saving record to CK: \(error), \(error.localizedDescription)")
                    completion(false)
                    return
                }
                
                guard let record = record else { completion(false); return }
                let user = User(record: record)
                self.loggedInUser = user
            })
            completion(true)
        }
    }
    
    func fetchLoggedInUser(completion: @escaping (Bool) -> Void) {
        CloudKitManager.shared.fetchLoggedInUserRecord { (userRecord, error) in
            if let error = error {
                print("Error fetching logged in user: \(error), \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard let userRecord = userRecord else { completion(false); return }
            
            let user = User(record: userRecord)
            
            self.loggedInUser = user
            completion(true)
        }
    }
    
    func fetchUsersWith(searchTerm: String, completion: @escaping ([CNContact]?, [User]?) -> Void) {
        var usernameSearchResults: [User] = []
        var contactsSearchResults: [CNContact] = []
        
        //Search for username in CloudKit
        let predicate = NSPredicate(format: "%K == %@", argumentArray: [User.usernameKey, searchTerm])
        CloudKitManager.shared.fetchRecordsWithType(User.typeKey, predicate: predicate, recordFetchedBlock: nil) { (records, error) in
            if let error = error {
                print("Error fetching records for \(searchTerm): \(error), \(error.localizedDescription)")
                completion(nil, nil)
                return
            }
            
            guard let records = records else { completion(nil, nil); return }
            let results = records.compactMap({ (record) -> User? in
                guard let user = User(record: record) else { completion(nil, nil); return nil }
                return user
            })
            usernameSearchResults = results
        }
        
        //Search for name in contacts
        contactsSearchResults = ContactController.shared.contacts.filter({ (contact) -> Bool in
            return contact.givenName.contains(searchTerm) || contact.familyName.contains(searchTerm)
        })
        
        completion(contactsSearchResults, usernameSearchResults)
    }
    
    func fetchUserWith(phoneNumber: String, completion: @escaping (User?) -> Void) {
        let predicate = NSPredicate(format: "%K == %@", argumentArray: [User.phoneNumberKey, phoneNumber])
        
        CloudKitManager.shared.fetchRecordsWithType(User.typeKey, predicate: predicate, recordFetchedBlock: nil) { (records, error) in
            if let error = error {
                print("Error fetching records for \(phoneNumber): \(error), \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let records = records, records.count > 0 else { completion(nil); return }
            let user = User(record: records.first!)
            completion(user)
        }
    }
    
    func fetchAllUsers(completion: @escaping (Bool) -> Void) {
        
        CloudKitManager.shared.fetchRecordsWithType(User.typeKey, predicate: NSPredicate(value: true), recordFetchedBlock: nil) { (records, error) in
            if let error = error {
                print("Error fetching users from CK: \(error), \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard let records = records else { completion(false); return }
            
            for record in records {
                let newUser = User(record: record)
                guard let user = newUser else { completion(false); return }
                self.users.append(user)
            }
        }
        completion(true)
    }
    
    func modify(user: User, withUsername username: String?, profileImage: UIImage?, completion: @escaping (Bool) -> Void) {
        //Update local user object
        if username != nil {
            user.username = username!
        }
        if profileImage != nil {
            user.profileImage = profileImage!
        }
        
        guard let record = CKRecord(user: user) else { return }
        
        //Update CloudKit
        CloudKitManager.shared.modifyRecords([record], perRecordCompletion: nil) { (_, error) in
            if let error = error {
                print("Error modifying the user: \(user.username); \(error.localizedDescription)")
                completion(false)
                return
            }
        }
        completion(true)
    }

    func delete(user: User, completion: @escaping (Bool) -> Void) {
        //Delete the local instance
        guard let indexToRemove = users.index(of: user) else { completion(false); return }
        
        users.remove(at: indexToRemove)
        
        //Delete from CloudKit
        let recordID = user.ckRecord
        CloudKitManager.shared.deleteRecordWithID(recordID) { (_, error) in
            if let error = error {
                print("Unable to delete user: \(user.username); \(error.localizedDescription)")
                completion(false)
                return
            }
        }
        completion(true)
    }
}

