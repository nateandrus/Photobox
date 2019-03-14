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
    
    static let typeKey = "Event"
    static let attendeesKey = "attendees"
    fileprivate static let eventTitleKey = "eventTitle"
    fileprivate static let eventImage = "eventImage"
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
    
    init(attendees: [User] = [], eventImage: UIImage = #imageLiteral(resourceName: "calendar icon"), eventTitle: String, location: String, startTime: Date, endTime: Date, description: String?, eventPhotos: [Photo] = [], creatorReference: CKRecord.Reference) {
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
    
    init?(record: CKRecord) {
        guard let eventTitle = record[Event.eventTitleKey] as? String,
            let eventImage = record[Event.eventImage] as? UIImage,
            let location = record[Event.locationKey] as? String,
            let attendees = record[Event.attendeesKey] as? [User],
            let startTime = record[Event.startTimeKey] as? Date,
            let endTime = record[Event.endTimeKey] as? Date,
            let description = record[Event.descriptionKey] as? String?,
            let eventPhotos = record[Event.eventPhotosKey] as? [Photo]?,
            let creatorReference = record[Event.creatorReferenceKey] as? CKRecord.Reference
            else { return nil }
        self.eventTitle = eventTitle
        self.eventImage = eventImage
        self.location = location
        self.attendees = attendees
        self.startTime = startTime
        self.endTime = endTime
        self.description = description
        self.eventPhotos = eventPhotos
        self.ckrecordID = CKRecord.ID(recordName: self.eventTitle)
        self.creatorReference = creatorReference
    }
}
extension Event: Equatable {
    static func == (lhs: Event, rhs: Event) -> Bool {
        return lhs.ckrecordID == rhs.ckrecordID
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
