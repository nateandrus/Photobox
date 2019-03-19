//
//  Photo.swift
//  Photobox
//
//  Created by Nathan Andrus on 3/12/19.
//  Copyright © 2019 Nathan Andrus. All rights reserved.
//

import UIKit
import CloudKit

class Photo {
    
    static let typeKey = "Photo"
    static let timestampKey = "timestamp"
    static let eventReference = "eventReference"
    static let userReference = "userReference"
    static let photoKey = "photo"
    static let recordID = "photoRecordID"
    
    
    
    var photoData: Data?
    let timestamp: Date
    let eventReference: CKRecord.Reference
    let userReference: CKRecord.Reference
    let photoRecordID: CKRecord.ID
    var image: UIImage? {
        get {
            guard let photoData = photoData else { return nil }
            return UIImage(data: photoData)
        }
        set {
            photoData = newValue?.jpegData(compressionQuality: 0.5)
        }
    }
    
    var imageAsset: CKAsset? {
        get {
            let temporaryDirectory = NSTemporaryDirectory()
            let temporaryDirectoryURL = URL(fileURLWithPath: temporaryDirectory)
            let fileURL = temporaryDirectoryURL.appendingPathComponent(photoRecordID.recordName).appendingPathComponent("jpg")
            do {
                try photoData?.write(to: fileURL)
            } catch let error {
                print("Error writing to URL: \(error), \(error.localizedDescription)")
            }
            return CKAsset(fileURL: fileURL)
        }
    }
    
    init(image: UIImage, timestamp: Date = Date(), eventReference: CKRecord.Reference, userReference: CKRecord.Reference, photoRecordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.timestamp = timestamp
        self.eventReference = eventReference
        self.userReference = userReference
        self.photoRecordID = photoRecordID
        self.image = image
    }
    
    init?(ckRecord: CKRecord) {
        guard let timestamp = ckRecord[Photo.timestampKey] as? Date,
            let eventReference = ckRecord[Photo.eventReference] as? CKRecord.Reference,
            let userReference = ckRecord[Photo.userReference] as? CKRecord.Reference,
            let photoAsset = ckRecord[Photo.photoKey] as? CKAsset else { return nil }
        
        let photoData = try? Data(contentsOf: photoAsset.fileURL)
        self.timestamp = timestamp
        self.photoRecordID = ckRecord.recordID
        self.eventReference = eventReference
        self.userReference = userReference
        self.photoData = photoData
    }
}


