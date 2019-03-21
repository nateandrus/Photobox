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
    
    var pastEvents: [Event] = []
    var currentEvents: [Event] = []
    var futureEvents: [Event] = []
    
    
    let publicDB = CKContainer.default().publicCloudDatabase
    
    // MARK: - CRUD Functions
    func createEvent(eventImage: UIImage, eventTitle: String, location: String, startTime: Date, endTime: Date, description: String, invitedUsers: [CKRecord.Reference]?, completion: @escaping (Bool) -> Void) {
        guard let loggedinInUser = UserController.shared.loggedInUser else { completion(false); return }
        
        let creatorReference = CKRecord.Reference(recordID: loggedinInUser.ckRecord, action: .none)
        
        let defaultPhoto = Photo(image: eventImage, timestamp: Date(), eventReference: nil, userReference: creatorReference)
        
        guard let photoRecord = CKRecord(photo: defaultPhoto) else { completion(false); return }
        CloudKitManager.shared.saveRecord(photoRecord) { (photoRecord, error) in
            if let error = error {
                print("Error saving record to CloudKit: \(error), \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard let photoRecord = photoRecord else { completion(false); return }
            let photoReference = CKRecord.Reference(record: photoRecord, action: .deleteSelf)
            let newEvent = Event(attendees: [creatorReference], eventImage: eventImage, eventTitle: eventTitle, location: location, startTime: startTime, endTime: endTime, description: description, eventPhotos: [photoReference], creatorReference: creatorReference, invitedUsers: invitedUsers)
            UserController.shared.events.append(newEvent)
            self.sortEvents(completion: { (success) in
            })
            
            guard let record = CKRecord(event: newEvent) else { completion(false); return }
            
            CloudKitManager.shared.saveRecord(record) { (record, error) in
                if let error = error {
                    print("Error saving record to CloudKit: \(error), \(error.localizedDescription)")
                    completion(false)
                    return
                }
                
                completion(true)
                return
            }
        }
    }
    
    func fetchEvents(completion: @escaping (Bool) -> Void) {
        guard let loggedInUser = UserController.shared.loggedInUser else { completion(false); return }
        
        let reference = CKRecord.Reference(recordID: loggedInUser.ckRecord, action: .none)
        let predicate = NSPredicate(format: "%@ IN attendees", reference)

        CloudKitManager.shared.fetchRecordsWithType(Event.typeKey, predicate: predicate, recordFetchedBlock: nil) { (records, error) in
            if let error = error {
                print("Error fetching user events: \(error), \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard let records = records else { completion(false); return }
            UserController.shared.events = []
            for record in records {
                guard let event = Event(record: record) else { completion(false); return }
                UserController.shared.events.append(event)
                if record == records.last {
                    self.sortEvents(completion: { (_) in
                        completion(true)
                    })
                }
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
        guard let indexToDelete = UserController.shared.events.index(of: event) else { completion(false); return }
        UserController.shared.events.remove(at: indexToDelete)
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
    
    func removeAttendee(creatorReference: CKRecord.Reference, fromEvent event: Event, completion: @escaping (Bool) -> Void) {
        //Remove local attendee
        guard let attendeeIndex = event.attendees.index(of: creatorReference) else { completion(false); return }
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
    
    func sortEvents(completion: @escaping (Bool) -> Void) {
        pastEvents.removeAll()
        currentEvents.removeAll()
        futureEvents.removeAll()
        let events = UserController.shared.events
        for event in events {
            if event.startTime > Date() {
                self.futureEvents.append(event)
            }else if event.endTime < Date() {
                self.pastEvents.append(event)
            } else {
                self.currentEvents.append(event)
            }
            if event == events.last {
                completion(true)
            }
        }
    }
}
