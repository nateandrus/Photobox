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
    fileprivate static let imageAssetKey = "imageAsset"
    fileprivate static let locationKey = "location"
    fileprivate static let startTimeKey = "startTime"
    fileprivate static let endTimeKey = "endTime"
    fileprivate static let descriptionKey = "description"
    fileprivate static let eventPhotosKey = "eventPhotos"
    fileprivate static let creatorReferenceKey = "creatorReference"
    fileprivate static let invitedUsersKey = "invitedUsers"
    
    var attendees: [CKRecord.Reference]
    var eventPhotoData: Data?
    var eventImage: UIImage? {
        get {
            guard let photoData = eventPhotoData else { return nil }
            return UIImage(data: photoData)
        }
        set {
            eventPhotoData = newValue?.jpegData(compressionQuality: 0.5)
        }
    }
    
    var imageAsset: CKAsset? {
        get {
            let temporaryDirectory = NSTemporaryDirectory()
            let temporaryDirectoryURL = URL(fileURLWithPath: temporaryDirectory)
            let fileURL = temporaryDirectoryURL.appendingPathComponent(ckrecordID.recordName).appendingPathExtension("jpg")
            do {
                try eventPhotoData?.write(to: fileURL)
            } catch let error {
                print("Error writing to URL: \(error), \(error.localizedDescription)")
            }
            return CKAsset(fileURL: fileURL)
        }
    }
    var eventTitle: String
    var location: String
    var startTime: Date
    var endTime: Date
    var description: String?
    var eventPhotos: [CKRecord.Reference]?
    let ckrecordID: CKRecord.ID
    let creatorReference: CKRecord.Reference?
    var invitedUsers: [CKRecord.Reference]?
    
    init(attendees: [CKRecord.Reference] = [], eventImage: UIImage = #imageLiteral(resourceName: "calendar icon"), eventTitle: String, location: String, startTime: Date, endTime: Date, description: String?, eventPhotos: [CKRecord.Reference], creatorReference: CKRecord.Reference?, invitedUsers: [CKRecord.Reference]? = []) {

        self.attendees = attendees
        self.eventTitle = eventTitle
        self.location = location
        self.startTime = startTime
        self.endTime = endTime
        self.description = description
        self.eventPhotos = eventPhotos
        self.ckrecordID = CKRecord.ID(recordName: UUID().uuidString)
        self.creatorReference = creatorReference
        self.invitedUsers = invitedUsers
        self.eventImage = eventImage
    }
    
    init?(record: CKRecord) {
        guard let imageAsset = record[Event.imageAssetKey] as? CKAsset,
            let eventTitle = record[Event.eventTitleKey] as? String,
            let location = record[Event.locationKey] as? String,
            let attendees = record[Event.attendeesKey] as? [CKRecord.Reference],
            let startTime = record[Event.startTimeKey] as? Date,
            let endTime = record[Event.endTimeKey] as? Date,
            let description = record[Event.descriptionKey] as? String?,
            let eventPhotos = record[Event.eventPhotosKey] as? [CKRecord.Reference]?,
            let creatorReference = record[Event.creatorReferenceKey] as? CKRecord.Reference?,
            let invitedUsers = record[Event.invitedUsersKey] as? [CKRecord.Reference]?
            else { return nil }
        
        guard let photoData = try? Data(contentsOf: imageAsset.fileURL) else { return nil }
        
        self.eventPhotoData = photoData
        self.eventTitle = eventTitle
        self.location = location
        self.attendees = attendees
        self.startTime = startTime
        self.endTime = endTime
        self.description = description
        self.eventPhotos = eventPhotos
        self.ckrecordID = record.recordID
        self.creatorReference = creatorReference
        self.invitedUsers = invitedUsers
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
        self.setValue(event.imageAsset, forKey: Event.imageAssetKey)
        self.setValue(event.location, forKey: Event.locationKey)
        self.setValue(event.startTime, forKey: Event.startTimeKey)
        self.setValue(event.endTime, forKey: Event.endTimeKey)
        self.setValue(event.description, forKey: Event.descriptionKey)
        self.setValue(event.eventPhotos, forKey: Event.eventPhotosKey)
        self.setValue(event.creatorReference, forKey: Event.creatorReferenceKey)
        self.setValue(event.invitedUsers, forKey: Event.invitedUsersKey)
    }
}
