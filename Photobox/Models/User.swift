//
//  User.swift
//  Photobox
//
//  Created by Nathan Andrus on 3/11/19.
//  Copyright © 2019 Nathan Andrus. All rights reserved.
//

import UIKit
import CloudKit

class User {
    
    static let typeKey = "User"
    static let usernameKey = "username"
    fileprivate static let profileImageKey = "profileImage"
    static let creatorReferenceKey = "creatorReference"

    var username: String
    var profileImage: UIImage?
    let ckRecord: CKRecord.ID
    let creatorReference: CKRecord.Reference
    
    init(username: String, profileImage: UIImage? = nil, ckRecord: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), creatorReference: CKRecord.Reference) {
        self.username = username
        self.profileImage = profileImage
        self.ckRecord = ckRecord
        self.creatorReference = creatorReference
    }
    
    convenience init?(record: CKRecord) {
        guard let username = record[User.usernameKey] as? String,
            let profileImage = record[User.profileImageKey] as? UIImage,
            let creatorReference = record[User.creatorReferenceKey] as? CKRecord.Reference else { return nil}
        self.init(username: username, profileImage: profileImage, ckRecord: record.recordID, creatorReference: creatorReference)
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

