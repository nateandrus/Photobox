//
//  EventController.swift
//  Photobox
//
//  Created by Nathan Andrus on 3/11/19.
//  Copyright © 2019 Nathan Andrus. All rights reserved.
//

import UIKit
import CloudKit

class EventController {
    
    static let shared = EventController()
    
    var events: [Event] = []
    
    var attendees: [User] = []
    
    let publicDB = CKContainer.default().publicCloudDatabase
    
    //CRUD Functions
    //save to icloud
    func save(event: Event, completion: @escaping (Bool) -> Void) {
        guard let record = CKRecord(event: event) else { completion(false); return }
        publicDB.save(record) { (record, error) in
            if let error = error {
                print("Error saving to cloudkit: \(error)")
                completion(false)
                return
            }
            self.events.append(event)
            completion(true)
        }
    }
    
    //create
    func createEvent(eventImage: UIImage, eventTitle: String, location: String, startTime: Date, endTime: Date, description: String, completion: @escaping (Bool) -> Void) {
        guard let logginInUser = UserController.shared.loggedInUser else { completion(false); return }
        let creatorReference = CKRecord.Reference(recordID: logginInUser.ckRecord, action: .deleteSelf)
        let newEvent = Event(eventImage: eventImage, eventTitle: eventTitle, location: location, startTime: startTime, endTime: endTime, description: description, creatorReference: creatorReference)
        save(event: newEvent) { (success) in
            if success {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    //read
    func fetchEvents(completion: @escaping (Bool) -> Void) {
        guard let logginInUser = UserController.shared.loggedInUser else { completion(false); return }
        let creatorReference = CKRecord.Reference(recordID: logginInUser.ckRecord, action: .deleteSelf)
        let predicate = NSPredicate(format: "%K == %@", argumentArray: [creatorReference, attendees])
        let query = CKQuery(recordType: Event.typeKey, predicate: predicate)
        publicDB.perform(query, inZoneWith: nil) { (events, error) in
            if let error = error {
                print("There was an error fetching events from cloudkit: \(error.localizedDescription)")
                completion(false)
                return
            }
            guard let events = events else { completion(false); return }
            let eventsArray = events.compactMap({ Event(record: $0 )})
            self.events = eventsArray
            completion(true)
        }
    }
}
