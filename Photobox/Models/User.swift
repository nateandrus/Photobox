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
    fileprivate static let firstNameKey = "firstName"
    fileprivate static let lastNameKey = "lastName"
    fileprivate static let profileImageKey = "profileImageData"
    static let creatorReferenceKey = "creatorReference"
    static let phoneNumberKey = "phoneNumber"
    static let userEventsKey = "userEvents"
    static let invitedEventsKey = "invitedEvents"

    var username: String?
    var password: String?
    var firstName: String?
    var lastName: String?
    var profileImageData: Data?
    var imageAsset: CKAsset? {
        get {
            let temporaryDirectory = NSTemporaryDirectory()
            let temporaryDirectoryURL = URL(fileURLWithPath: temporaryDirectory)
            
            let fileURL = temporaryDirectoryURL.appendingPathComponent(ckRecord.recordName).appendingPathExtension("jpg")
            do {
                try profileImageData?.write(to: fileURL)
            } catch let error {
                print("Error writing to URL: \(error), \(error.localizedDescription)")
            }
            return CKAsset(fileURL: fileURL)
        }
    }
    var profileImage: UIImage? {
        get {
            guard let profileImageData = profileImageData else { return nil }
            return UIImage(data: profileImageData)
        }
        set {
            profileImageData = newValue?.jpegData(compressionQuality: 0.5)
        }
    }
    let ckRecord: CKRecord.ID
    let creatorReference: CKRecord.Reference?
    var phoneNumber: String
    var invitedEvents: [CKRecord.Reference]
    
    init(username: String?, password: String?, firstName: String? = nil, lastName: String? = nil, profileImage: UIImage = #imageLiteral(resourceName: "default user icon"), ckRecord: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), creatorReference: CKRecord.Reference?, phoneNumber: String, invitedEvents: [CKRecord.Reference] = []) {
        self.firstName = firstName
        self.lastName = lastName
        self.username = username
        self.password = password
        self.ckRecord = ckRecord
        self.creatorReference = creatorReference
        self.phoneNumber = phoneNumber
        self.invitedEvents = invitedEvents
        self.profileImage = profileImage
    }
    
    init?(record: CKRecord) {
        guard let username = record[User.usernameKey] as? String,
            let password = record[User.passwordKey] as? String,
            let profileImageAsset = record[User.profileImageKey] as? CKAsset,
            let phoneNumber = record[User.phoneNumberKey] as? String,
            let creatorReference = record[User.creatorReferenceKey] as? CKRecord.Reference else { return nil }
        
        guard let photoData = try? Data(contentsOf: profileImageAsset.fileURL) else { return nil }
        let firstName = record[User.firstNameKey] as? String
        let lastName = record[User.lastNameKey] as? String
        let invitedEvents = record[User.invitedEventsKey] as? [CKRecord.Reference]
        
        self.profileImageData = photoData
        self.firstName = firstName
        self.lastName = lastName
        self.username = username
        self.password = password
        self.phoneNumber = phoneNumber
        self.invitedEvents = invitedEvents ?? []
        self.ckRecord = record.recordID
        self.creatorReference = creatorReference
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
        setValue(user.imageAsset, forKey: User.profileImageKey)
        setValue(user.phoneNumber, forKey: User.phoneNumberKey)
        setValue(user.creatorReference, forKey: User.creatorReferenceKey)
        if !user.invitedEvents.isEmpty {
            setValue(user.invitedEvents, forKey: User.invitedEventsKey)
        }
    }
}

