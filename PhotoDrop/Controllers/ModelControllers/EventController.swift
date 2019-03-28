//
//  EventController.swift
//  Photobox
//
//  Created by Nathan Andrus on 3/11/19.
//  Copyright © 2019 Nathan Andrus. All rights reserved.
//

import UIKit
import CloudKit
import UserNotifications

class EventController {
    
    // MARK: - Shared Instance/Singleton
    static let shared = EventController()
    
    var pastEvents: [Event] = []
    var currentEvents: [Event] = []
    var futureEvents: [Event] = []
    
    
    let publicDB = CKContainer.default().publicCloudDatabase
    
    // MARK: - CRUD Functions
    func createEvent(eventImage: UIImage, eventTitle: String, location: String, startTime: Date, endTime: Date, description: String?, invitedUsers: [CKRecord.Reference]?, completion: @escaping (Bool, Event?) -> Void) {
        guard let loggedinInUser = UserController.shared.loggedInUser else { completion(false, nil); return }
        
        let creatorReference = CKRecord.Reference(recordID: loggedinInUser.ckRecord, action: .none)
        
        let defaultPhoto = Photo(image: eventImage, timestamp: Date(), eventReference: nil, userReference: creatorReference)
        
        guard let photoRecord = CKRecord(photo: defaultPhoto) else { completion(false, nil); return }
        CloudKitManager.shared.saveRecord(photoRecord) { (photoRecord, error) in
            if let error = error {
                print("Error saving record to CloudKit: \(error), \(error.localizedDescription)")
                completion(false, nil)
                return
            }
            
            guard let photoRecord = photoRecord else { completion(false, nil); return }
            let photoReference = CKRecord.Reference(record: photoRecord, action: .none)
            let newEvent = Event(attendees: [creatorReference], eventImage: eventImage, eventTitle: eventTitle, location: location, startTime: startTime, endTime: endTime, description: description, eventPhotos: [photoReference], creatorReference: creatorReference, invitedUsers: invitedUsers)
            
            UserController.shared.events.append(newEvent)
            self.scheduleUserNotificationForStartTime(for: newEvent)
            let date = Date(timeInterval: 86400, since: Date())
            if newEvent.startTime > date {
                self.scheduleUserNotification24HRSBefore(for: newEvent)
            }
            self.sortEvents(completion: { (success) in
                self.sortByTimeStamp()
            })
            
            guard let record = CKRecord(event: newEvent) else { completion(false, nil); return }
            
            CloudKitManager.shared.saveRecord(record) { (record, error) in
                if let error = error {
                    print("Error saving record to CloudKit: \(error), \(error.localizedDescription)")
                    completion(false, nil)
                    return
                }
                
                guard let record = record else { return }
                let eventReference = CKRecord.Reference(record: record, action: .none)
                
                defaultPhoto.eventReference = eventReference
                
                guard let newPhotoRecord = CKRecord(photo: defaultPhoto) else { completion(false, nil); return }
                CloudKitManager.shared.modifyRecords([newPhotoRecord], perRecordCompletion: nil, completion: { (_, error) in
                    if let error = error {
                        print("Error modifying photo record: \(error), \(error.localizedDescription)")
                        completion(false, nil)
                    }
                    completion(true, newEvent)
                    return
                })
                
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
            if records.count == 0 {
                EventController.shared.futureEvents = []
                EventController.shared.currentEvents = []
                EventController.shared.pastEvents = []
                completion(true)
            }
            for record in records {
                guard let event = Event(record: record) else { completion(false); return }
                UserController.shared.events.append(event)
                if record == records.last {
                    self.sortEvents(completion: { (_) in
                        self.sortByTimeStamp()
                        print(records.count)
                        completion(true)
                    })
                }
            }
        }
    }
    
    func modify(event: Event, withTitle title: String?, image: UIImage?, location: String?, startTime: Date?, endTime: Date?, description: String?, invitedUsers: [CKRecord.Reference]?, eventPhotos: [CKRecord.Reference]?, attendees: [CKRecord.Reference]?) {
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
        if invitedUsers != nil {
            event.invitedUsers = invitedUsers!
        }
        if eventPhotos != nil {
            event.eventPhotos = eventPhotos!
        }
        if attendees != nil {
            event.attendees = attendees!
        }
        
        guard let record = CKRecord(event: event) else { return }
        //Update CloudKit
        CloudKitManager.shared.modifyRecords([record], perRecordCompletion: nil) { (_, error) in
            if let error = error {
                print("Error modifying the event: \(event.eventTitle); \(error), \(error.localizedDescription)")
                return
            }
        }
    }
    
    func delete(event: Event, completion: @escaping (Bool) -> Void) {
        //Delete local instance
        guard let indexToDelete = UserController.shared.events.firstIndex(of: event) else { completion(false); return }
        UserController.shared.events.remove(at: indexToDelete)
        EventController.shared.cancelUserNotifications(for: event)
        //Delete from CloudKit
        let recordID = event.ckrecordID
        let reference = CKRecord.Reference(recordID: recordID, action: .none)
        
        if let invitedUsers = event.invitedUsers {
            // Modify the invitedEvents variable for each invited user
            let dispatchGroup = DispatchGroup()
            for userRef in invitedUsers {
                dispatchGroup.enter()
                let recordID = userRef.recordID
                CloudKitManager.shared.fetchRecord(withID: recordID) { (record, error) in
                    if let error = error {
                        print("Error fetching record from CloudKit: \(error), \(error.localizedDescription)")
                        completion(false)
                        return
                    }
                    
                    guard let record = record else { completion(false); return }
                    
                    guard let user = User(record: record),
                        var invitedEvents = user.invitedEvents,
                        let indexToRemove = invitedEvents.firstIndex(of: reference) else { completion(false); return }
                    invitedEvents.remove(at: indexToRemove)
                    
                    UserController.shared.modify(user: user, withUsername: nil, password: nil, profileImage: nil, invitedEvents: invitedEvents, completion: nil)
                    dispatchGroup.leave()
                }
                
            }
            
            dispatchGroup.notify(queue: .main) {
                CloudKitManager.shared.deleteRecordWithID(recordID) { (_, error) in
                    if let error = error {
                        print("Unable to delete event: \(event.eventTitle); \(error.localizedDescription)")
                        completion(false)
                        return
                    }
                    
                    completion(true)
                    return
                }
            }
        } else {
            CloudKitManager.shared.deleteRecordWithID(recordID) { (_, error) in
                if let error = error {
                    print("Unable to delete event: \(event.eventTitle); \(error.localizedDescription)")
                    completion(false)
                    return
                }
            }
            completion(true)
        }
    }
    
//    func fetchAttendeesFrom(event: Event, completion: @escaping ([User]?) -> Void) {
//        var users: [User] = []
//        
//        let dispatchGroup = DispatchGroup()
//        for attendee in event.attendees {
//            dispatchGroup.enter()
//            let userRecordID = attendee.recordID
//            let userRecord = CKRecord(recordType: User.typeKey, recordID: userRecordID)
//            guard let user = User(record: userRecord) else { completion(nil); return }
//            users.append(user)
//            
//            dispatchGroup.leave()
//        }
//        
//        dispatchGroup.notify(queue: .main) {
//            completion(users)
//        }
//    }
    
    func removeAttendee(creatorReference: CKRecord.Reference, fromEvent event: Event, completion: @escaping (Bool) -> Void) {
        //Remove local attendee
        guard let attendeeIndex = event.attendees.firstIndex(of: creatorReference) else { completion(false); return }
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
    
    func sortByTimeStamp() {
        self.futureEvents.sort(by: { $0.startTime < $1.startTime })
        self.pastEvents.sort(by: { $0.startTime < $1.startTime })
        self.currentEvents.sort(by: { $0.endTime < $1.endTime })
    }
}

protocol EventNotifications {
    func scheduleUserNotificationForStartTime(for event: Event)
    func scheduleUserNotification24HRSBefore(for event: Event)
    func cancelUserNotifications(for event: Event)
}

extension EventController: EventNotifications {
    func scheduleUserNotificationForStartTime(for event: Event) {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = event.eventTitle
        notificationContent.body = "Your event has begun!"
        notificationContent.badge = 1
        notificationContent.sound = UNNotificationSound.default
        
        let date = event.startTime
        let components = Calendar.current.dateComponents([.hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let notificationRequest = UNNotificationRequest(identifier: event.eventTitle, content: notificationContent, trigger: trigger)
        UNUserNotificationCenter.current().add(notificationRequest) { (error) in
            if let error = error {
                print(error, error.localizedDescription)
            }
        }
    }
    
    func scheduleUserNotification24HRSBefore(for event: Event) {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "24 hours until \(event.eventTitle)"
        notificationContent.body = "It's coming up fast!"
        notificationContent.badge = 1
        notificationContent.sound = UNNotificationSound.default
        
        let date = Date(timeInterval: -86400, since: event.startTime)
        let components = Calendar.current.dateComponents([.hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let notificationRequest = UNNotificationRequest(identifier: event.eventTitle, content: notificationContent, trigger: trigger)
        UNUserNotificationCenter.current().add(notificationRequest) { (error) in
            if let error = error {
                print(error, error.localizedDescription)
            }
        }
    }
    
    func cancelUserNotifications(for event: Event) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [event.eventTitle])
    }
}
