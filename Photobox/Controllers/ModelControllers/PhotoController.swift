//
//  PhotoController.swift
//  Photobox
//
//  Created by Nathan Andrus on 3/21/19.
//  Copyright © 2019 Nathan Andrus. All rights reserved.
//

import UIKit
import CloudKit

class PhotoController {
    
    static let shared = PhotoController()
    
    var collectionViewPhotos: [Photo] = []
    
    func addPhoto(toEvent: CKRecord.Reference, withImage: UIImage, userReference: CKRecord.Reference, timestamp: Date, completion: @escaping (Bool) -> Void) {
        
        let photo = Photo(image: withImage, timestamp: timestamp, eventReference: toEvent, userReference: userReference)
        collectionViewPhotos.append(photo)
        let record = CKRecord(photo: photo)
        
        guard let recordToSave = record else { completion(false); return }
        
        CloudKitManager.shared.saveRecord(recordToSave) { (record, error) in
            if let error = error {
                print("Error saving photo to cloudkit: \(error.localizedDescription)")
                completion(false)
                return
            }
            completion(true)
            return 
        }
    }
    
    func fetchCollectionViewPhotos(event: Event, completion: @escaping (Bool) -> Void) {
        
        let eventReference = CKRecord.Reference(recordID: event.ckrecordID, action: .none)
        
        let predicate = NSPredicate(format: "%@ == eventReference", eventReference)
        let query = CKQuery(recordType: Photo.typeKey, predicate: predicate)
        CKContainer.default().publicCloudDatabase.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("There was an error fetching records: \(error.localizedDescription)")
                completion(false)
                return
            }
            guard let records = records else { completion(false); return }
            self.collectionViewPhotos = []
            for record in records {
                guard let photo = Photo(ckRecord: record) else { completion(false); return }
                self.collectionViewPhotos.append(photo)
            }
            completion(true)
        }
    }
}
