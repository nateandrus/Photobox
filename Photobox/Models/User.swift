//
//  User.swift
//  Photobox
//
//  Created by Nathan Andrus on 3/11/19.
//  Copyright © 2019 Nathan Andrus. All rights reserved.
//

import UIKit
import CloudKit
import Contacts

class User {
    
    static let typeKey = "User"
    static let usernameKey = "username"
    fileprivate static let passwordKey = "password"
    fileprivate static let profileImageKey = "profileImage"
    static let creatorReferenceKey = "creatorReference"
    static let phoneNumberKey = "phoneNumber"
    static let pastEventsKey = "pastEvents"
    static let currentEventsKey = "currentEvents"
    static let futureEventsKey = "futureEvents"
    static let invitedEventsKey = "invitedEvents"

    var username: String
    var password: String
    var profileImage: UIImage?
    let ckRecord: CKRecord.ID
    let creatorReference: CKRecord.Reference
    var phoneNumber: String
    var pastEvents: [Event]?
    var currentEvents: [Event]?
    var futureEvents: [Event]?
    var invitedEvents: [Event]?
    
    init(username: String, password: String, profileImage: UIImage? = nil, ckRecord: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), creatorReference: CKRecord.Reference, phoneNumber: String, pastEvents: [Event]? = nil, currentEvents: [Event]? = nil, futureEvents: [Event]? = nil, invitedEvents: [Event]? = nil) {
        self.username = username
        self.password = password
        self.profileImage = profileImage
        self.ckRecord = ckRecord
        self.creatorReference = creatorReference
        self.phoneNumber = phoneNumber
        self.pastEvents = pastEvents
        self.currentEvents = currentEvents
        self.futureEvents = futureEvents
        self.invitedEvents = invitedEvents
    }
    
    convenience init?(record: CKRecord) {
        guard let username = record[User.usernameKey] as? String,
            let password = record[User.passwordKey] as? String,
            let phoneNumber = record[User.phoneNumberKey] as? String,
            let creatorReference = record[User.creatorReferenceKey] as? CKRecord.Reference else { return nil }
        
        self.init(username: username, password: password, profileImage: #imageLiteral(resourceName: "default user icon"), ckRecord: record.recordID, creatorReference: creatorReference, phoneNumber: phoneNumber)
    }
}
extension User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.ckRecord == rhs.ckRecord
    }
}

extension CKRecord {
    convenience init?(user: User) {
        self.init(recordType: User.typeKey, recordID: user.ckRecord)
        setValue(user.username, forKey: User.usernameKey)
        setValue(user.password, forKey: User.passwordKey)
        setValue(user.profileImage, forKey: User.profileImageKey)
        setValue(user.phoneNumber, forKey: User.phoneNumberKey)
        setValue(user.creatorReference, forKey: User.creatorReferenceKey)
        setValue(user.pastEvents, forKey: User.pastEventsKey)
        setValue(user.currentEvents, forKey: User.currentEventsKey)
        setValue(user.futureEvents, forKey: User.futureEventsKey)
        setValue(user.invitedEvents, forKey: User.invitedEventsKey)
    }
}

