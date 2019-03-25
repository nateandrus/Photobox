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
//    var invitedEvents: [Event] = []
    var users: [User] = []
    
    //MARK: - CRUD Functions
    func saveUserWith(username: String?, password: String?, phoneNumber: String?, completion: @escaping (Bool, User?) -> Void) {
        // If the user is saved with a username and password
        if username != nil {
            CKContainer.default().fetchUserRecordID { (appleUserRecordID, error) in
                if let error = error {
                    print("Error fetching user's apple ID: \(error.localizedDescription)")
                    completion(false, nil)
                    return
                }
                
                guard let appleUserRecordID = appleUserRecordID,
                    let phoneNumber = phoneNumber else { print(1); completion(false, nil); return }
                
                let reference = CKRecord.Reference(recordID: appleUserRecordID, action: .deleteSelf)
            
                let newUser = User(username: username, password: password, creatorReference: reference, phoneNumber: phoneNumber)
                
                guard let record = CKRecord(user: newUser) else { print(2); completion(false, nil); return }
                
                CloudKitManager.shared.saveRecord(record, completion: { (record, error) in
                    if let error = error {
                        print("Error saving record to CK: \(error), \(error.localizedDescription)")
                        completion(false, nil)
                        return
                    }
            
                    self.loggedInUser = newUser
                    
                    // Fetch the new user's first and last name from Cloud Kit
//                    guard let recordID = newUser.ckRecord else { completion(false); return }
                    
                    CloudKitManager.shared.fetchDiscoverableUserWith(recordID: appleUserRecordID) { (userID) in
                        guard let userID = userID else { print(3); completion(false, nil); return }
                        newUser.firstName = userID.nameComponents?.givenName
                        newUser.lastName = userID.nameComponents?.familyName
                    }
                    
                    // Update the record in CloudKit to include first and last name
                    guard let newRecord = CKRecord(user: newUser) else { print(4); completion(false, nil); return }
                    CloudKitManager.shared.modifyRecords([newRecord], perRecordCompletion: nil, completion: { (record, error) in
                        if let error = error {
                            print("Error modifying record in CloudKit: \(error), \(error.localizedDescription)")
                        }
                    })
                })
                completion(true, newUser)
            }
        }
        //If the user is created with only a phone number. This will happen if an event moderator invites someone from their contacts who isn't a registed member of photoBOX to join an event.
        else {
            guard let phoneNumber = phoneNumber else { print(5); completion(false, nil); return }
            
            let newUser = User(username: nil, password: nil, creatorReference: nil, phoneNumber: phoneNumber)
            guard let record = CKRecord(user: newUser) else { print(6); completion(false, nil); return }
            
            CloudKitManager.shared.saveRecord(record) { (record, error) in
                if let error = error {
                    print("Error saving record to CK: \(error), \(error.localizedDescription)")
                    completion(false, nil)
                    return
                }
            }
            completion(true, newUser)
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
            
            // Set the user's invited events to the source of truth
//            guard let invitedEvents = user?.invitedEvents.compactMap({ (reference) -> Event? in
//                let recordID = reference.recordID
//                let record = CKRecord(recordType: Event.typeKey, recordID: recordID)
//                return Event(record: record)
//            }) else { completion(false); return }
//            
//            self.invitedEvents = invitedEvents
            completion(true)
        }
    }
    
    func fetchUsersWith(searchTerm: String, completion: @escaping ([CNContact]?, [User]?) -> Void) {
        var usernameSearchResults: [User] = []
        var contactsSearchResults: [CNContact] = []
        
        if searchTerm.isEmpty {
            completion(nil, nil)
            return
        }
        
        //Search for username
        usernameSearchResults = users.filter({ (user) -> Bool in
            guard let username = user.username?.lowercased() else { return false }
            return username.starts(with: searchTerm)
        })
        
        //Search for name in contacts
        contactsSearchResults = ContactController.shared.contacts.filter({ (contact) -> Bool in
            let firstName = contact.givenName.lowercased()
            let lastName = contact.familyName.lowercased()
            return firstName.starts(with: searchTerm) || lastName.starts(with: searchTerm)
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
                guard let newUser = User(record: record) else { completion(false); return }
                self.users.append(newUser)
            }
            
            completion(true)
        }
    }
    
    func modify(user: User, withUsername username: String?, password: String?, profileImage: UIImage?, invitedEvents: [CKRecord.Reference]?, completion: ((Bool) -> Void)?) {
        //Update local user object
        if username != nil {
            user.username = username!
        }
        if password != nil {
            user.password = password!
        }
        if profileImage != nil {
            user.profileImage = profileImage!
        }
        if invitedEvents != nil {
            user.invitedEvents = invitedEvents!
        }
        
        guard let record = CKRecord(user: user) else { return }
        
        //Update CloudKit
        CloudKitManager.shared.modifyRecords([record], perRecordCompletion: nil) { (_, error) in
            if let error = error {
                print("Error modifying the user: \(user.username ?? ""); \(error.localizedDescription)")
                if completion != nil {
                    completion!(false)
                }
                return
            }
        }
        if completion != nil {
            completion!(true)
        }
    }

    func delete(user: User, completion: @escaping (Bool) -> Void) {
        //Delete the local instance
        guard let indexToRemove = users.index(of: user) else { completion(false); return }
        
        users.remove(at: indexToRemove)
        
        //Delete from CloudKit
        let recordID = user.ckRecord 
        CloudKitManager.shared.deleteRecordWithID(recordID) { (_, error) in
            if let error = error {
                print("Unable to delete user: \(user.username ?? ""); \(error.localizedDescription)")
                completion(false)
                return
            }
        }
        completion(true)
    }
}

