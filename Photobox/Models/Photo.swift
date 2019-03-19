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
    static let eventReferenceKey = "eventReference"
    static let userReferenceKey = "userReference"
    static let imageAssetKey = "imageAsset"
    static let recordID = "photoRecordID"
    
    var photoData: Data?
    let timestamp: Date
    let eventReference: CKRecord.Reference?
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
            let fileURL = temporaryDirectoryURL.appendingPathComponent(photoRecordID.recordName).appendingPathExtension("jpg")
            do {
                try photoData?.write(to: fileURL)
            } catch let error {
                print("Error writing to URL: \(error), \(error.localizedDescription)")
            }
            return CKAsset(fileURL: fileURL)
        }
    }
    
    init(image: UIImage, timestamp: Date = Date(), eventReference: CKRecord.Reference?, userReference: CKRecord.Reference, photoRecordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.timestamp = timestamp
        self.eventReference = eventReference
        self.userReference = userReference
        self.photoRecordID = photoRecordID
        self.image = image
    }
    
    init?(ckRecord: CKRecord) {
        guard let timestamp = ckRecord[Photo.timestampKey] as? Date,

            let userReference = ckRecord[Photo.userReferenceKey] as? CKRecord.Reference,
            let imageAsset = ckRecord[Photo.imageAssetKey] as? CKAsset else { return nil }
        
        guard let photoData = try? Data(contentsOf: imageAsset.fileURL) else { return nil }
        
        let eventReference = ckRecord[Photo.eventReferenceKey] as? CKRecord.Reference
        
        self.photoData = photoData
        self.timestamp = timestamp
        self.photoRecordID = ckRecord.recordID
        self.eventReference = eventReference
        self.userReference = userReference
    }
}
extension CKRecord {
    convenience init?(photo: Photo) {
        self.init(recordType: Photo.typeKey, recordID: photo.photoRecordID)
        setValue(photo.imageAsset, forKey: Photo.imageAssetKey)
        setValue(photo.timestamp, forKey: Photo.timestampKey)
        setValue(photo.eventReference, forKey: Photo.eventReferenceKey)
        setValue(photo.userReference, forKey: Photo.userReferenceKey)
    }
}


