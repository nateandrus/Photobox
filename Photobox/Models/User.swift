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
    fileprivate static let profileImageKey = "profileImage"
    static let creatorReferenceKey = "creatorReference"
    static let phoneNumberKey = "phoneNumber"

    var username: String
    var profileImage: UIImage?
    let ckRecord: CKRecord.ID
    let creatorReference: CKRecord.Reference
    let phoneNumber: CNPhoneNumber
    var pastEvents: [Event]
    var currentEvents: [Event]
    var futureEvents: [Event]
    var invitedEvents: [Event]
    
    init(username: String, profileImage: UIImage? = nil, ckRecord: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), creatorReference: CKRecord.Reference, phoneNumber: CNPhoneNumber, pastEvents: [Event] = [], currentEvents: [Event] = [], futureEvents: [Event] = [], invitedEvents: [Event] = []) {
        self.username = username
        self.profileImage = profileImage
        self.ckRecord = ckRecord
        self.creatorReference = creatorReference
        self.phoneNumber = phoneNumber
    }
    
    convenience init?(record: CKRecord) {
        guard let username = record[User.usernameKey] as? String,
            let profileImage = record[User.profileImageKey] as? UIImage,
            let creatorReference = record[User.creatorReferenceKey] as? CKRecord.Reference,
            let phoneNumber = record[User.phoneNumberKey] as? CNPhoneNumber
            else { return nil}
        self.init(username: username, creatorReference: creatorReference, phoneNumber: phoneNumber)
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
        setValue(user.profileImage, forKey: User.profileImageKey)
    }
}

