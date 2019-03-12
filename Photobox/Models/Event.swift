//
//  Event.swift
//  Photobox
//
//  Created by Nathan Andrus on 3/11/19.
//  Copyright © 2019 Nathan Andrus. All rights reserved.
//

import UIKit
import CloudKit

class Event {
    
    fileprivate static let typeKey = "Event"
    fileprivate static let attendeesKey = "attendees"
    fileprivate static let eventTitleKey = "eventTitle"
    fileprivate static let locationKey = "location"
    fileprivate static let startTimeKey = "startTime"
    fileprivate static let endTimeKey = "endTime"
    fileprivate static let descriptionKey = "description"
    fileprivate static let eventPhotosKey = "eventPhotos"
    fileprivate static let creatorReferenceKey = "creatorReference"
    
    var attendees: [User]
    var eventImage: UIImage
    var eventTitle: String
    var location: String
    var startTime: Date
    var endTime: Date
    var description: String?
    var eventPhotos: [Photo]?
    let ckrecordID: CKRecord.ID
    let creatorReference: CKRecord.Reference
    
    init(attendees: [User] = [], eventImage: UIImage, eventTitle: String, location: String, startTime: Date, endTime: Date, description: String?, eventPhotos: [Photo] = [], creatorReference: CKRecord.Reference) {
        self.attendees = attendees
        self.eventImage = eventImage
        self.eventTitle = eventTitle
        self.location = location
        self.startTime = startTime
        self.endTime = endTime
        self.description = description
        self.eventPhotos = eventPhotos
        self.ckrecordID = CKRecord.ID(recordName: self.eventTitle)
        self.creatorReference = creatorReference
    }
}

extension CKRecord {
    convenience init?(event: Event) {
        self.init(recordType: Event.typeKey, recordID: event.ckrecordID)
        self.setValue(event.attendees, forKey: Event.attendeesKey)
        self.setValue(event.eventTitle, forKey: Event.eventTitleKey)
        self.setValue(event.location, forKey: Event.locationKey)
        self.setValue(event.startTime, forKey: Event.startTimeKey)
        self.setValue(event.endTime, forKey: Event.endTimeKey)
        self.setValue(event.description, forKey: Event.descriptionKey)
        self.setValue(event.eventPhotos, forKey: Event.eventPhotosKey)
        self.setValue(event.creatorReference, forKey: Event.creatorReferenceKey)
    }
}
