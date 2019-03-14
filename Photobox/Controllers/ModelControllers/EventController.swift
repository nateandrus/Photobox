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
    
    // MARK: - Shared Instance/Singleton
    static let shared = EventController()
    
    // MARK: - Sources of Truth
    var events: [Event] = []
//    var attendees: [User] = []
    
    let publicDB = CKContainer.default().publicCloudDatabase
    
    // MARK: - CRUD Functions
    func createEvent(eventImage: UIImage, eventTitle: String, location: String, startTime: Date, endTime: Date, description: String, completion: @escaping (Bool) -> Void) {
        guard let loggedinInUser = UserController.shared.loggedInUser else { completion(false); return }
        
        let creatorReference = CKRecord.Reference(recordID: loggedinInUser.ckRecord, action: .deleteSelf)
        
        let newEvent = Event(attendees: [loggedinInUser], eventImage: eventImage, eventTitle: eventTitle, location: location, startTime: startTime, endTime: endTime, description: description, creatorReference: creatorReference)
        
        guard let record = CKRecord(event: newEvent) else { completion(false); return }
        
        CloudKitManager.shared.saveRecord(record) { (record, error) in
            if let error = error {
                print("Error saving record to CloudKit: \(error), \(error.localizedDescription)")
                completion(false)
                return
            }
            guard let record = record else { completion(false); return }
            
            guard let event = Event(record: record) else { completion(false); return }
            self.events.append(event)
        }
    }
    
    func fetchEvents(completion: @escaping (Bool) -> Void) {
        guard let loggedInUser = UserController.shared.loggedInUser else { completion(false); return }
        
        let predicate = NSPredicate(format: "%K IN $@", argumentArray: [loggedInUser, Event.attendeesKey])
        
        CloudKitManager.shared.fetchRecordsWithType(Event.typeKey, predicate: predicate, recordFetchedBlock: nil) { (records, error) in
            if let error = error {
                print("Error fetching user events: \(error), \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard let records = records else { completion(false); return }
            
            for record in records {
                guard let event = Event(record: record) else { completion(false); return }
                self.events.append(event)
            }
        }
    }
    
    func modify(event: Event, withTitle title: String?, image: UIImage?, location: String?, startTime: Date?, endTime: Date?, description: String?) {
        //Update local event object
        if title != nil {
            event.eventTitle = title!
        }
        if image != nil {
            event.eventImage = image!
        }
        if location != nil {
            event.location = location!
        }
        if startTime != nil {
            event.startTime = startTime!
        }
        if endTime != nil {
            event.endTime = endTime!
        }
        if description != nil {
            event.description = description!
        }
        
        guard let record = CKRecord(event: event) else { return }
        
        //Update CloudKit
        CloudKitManager.shared.modifyRecords([record], perRecordCompletion: nil) { (_, error) in
            if let error = error {
                print("Error modifying the event: \(event.eventTitle); \(error.localizedDescription)")
                return
            }
        }
    }
    
    func delete(event: Event, completion: @escaping (Bool) -> Void) {
        //Delete local instance
        guard let indexToDelete = events.index(of: event) else { completion(false); return }
        events.remove(at: indexToDelete)
        
        //Delete from CloudKit
        let recordID = event.ckrecordID
        CloudKitManager.shared.deleteRecordWithID(recordID) { (_, error) in
            if let error = error {
                print("Unable to delete event: \(event.eventTitle); \(error.localizedDescription)")
                completion(false)
                return
            }
        }
        completion(true)
    }
    
    func removeAttendee(user: User, fromEvent event: Event, completion: @escaping (Bool) -> Void) {
        //Remove local attendee
        guard let attendeeIndex = event.attendees.index(of: user) else { completion(false); return }
        event.attendees.remove(at: attendeeIndex)
        
        //Remove from CloudKit
        guard let eventRecord = CKRecord(event: event) else { completion(false); return }
        CloudKitManager.shared.modifyRecords([eventRecord], perRecordCompletion: nil) { (_, error) in
            if let error = error {
                print("Error removing attendee from CloudKit: \(error), \(error.localizedDescription)")
                completion(false)
                return
            }
        }
        completion(true)
    }
}
