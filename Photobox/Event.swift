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
    fileprivate static let timeKey = "time"
    fileprivate static let descriptionKey = "description"
    fileprivate static let eventPhotosKey = "eventPhotos"
    fileprivate static let creatorReferenceKey = "creatorReference"
    
    var attendees: [User]
    var eventImage: UIImage
    var eventTitle: String
    var location: String
    var time: Date
    var description: String?
    var eventPhotos: [UIImage]?
    let ckrecordID: CKRecord.ID
    let creatorReference: CKRecord.Reference
    
    init(attendees: [User], eventImage: UIImage, eventTitle: String, location: String, time: Date, description: String?, eventPhotos: [UIImage], creatorReference: CKRecord.Reference) {
        self.attendees = attendees
        self.eventImage = eventImage
        self.eventTitle = eventTitle
        self.location = location
        self.time = time
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
        self.setValue(event.time, forKey: Event.timeKey)
        self.setValue(event.description, forKey: Event.descriptionKey)
        self.setValue(event.eventPhotos, forKey: Event.eventPhotosKey)
        self.setValue(event.creatorReference, forKey: Event.creatorReferenceKey)
    }
}
