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
    
    func addPhoto(toEvent event: CKRecord.Reference, withImage: UIImage, userReference: CKRecord.Reference, timestamp: Date, completion: @escaping (Bool) -> Void) {
        
        let photo = Photo(image: withImage, timestamp: timestamp, eventReference: event, userReference: userReference)
        
        collectionViewPhotos.append(photo)
        
        let record = CKRecord(photo: photo)
        
        guard let recordToSave = record else { completion(false); return }
        
        CloudKitManager.shared.saveRecord(recordToSave) { (record, error) in
            if let error = error {
                print("Error saving photo to cloudkit: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard let record = record else { completion(false); return }
            
            let photoReference = CKRecord.Reference(record: record, action: .deleteSelf)
            
            CloudKitManager.shared.fetchRecord(withID: event.recordID, completion: { (record, error) in
                if let error = error {
                    print("Error fetching event record from cloudkit: \(error.localizedDescription)")
                    completion(false)
                    return
                }
                guard let record = record,
                    let event = Event(record: record) else { completion(false); return }
                
                
                event.eventPhotos?.append(photoReference)
                
                EventController.shared.modify(event: event, withTitle: nil, image: nil, location: nil, startTime: nil, endTime: nil, description: nil, eventPhotos: event.eventPhotos)
                
                completion(true)
                return
            })
        }
    }
    
    func fetchCollectionViewPhotos(event: Event, completion: @escaping (Bool) -> Void) {
        collectionViewPhotos.removeAll()
        
        guard let eventPhotos = event.eventPhotos else { completion(false); return }
        
        let dispatchGroup = DispatchGroup()
        for photoReference in eventPhotos {
            dispatchGroup.enter()
            CloudKitManager.shared.fetchRecord(withID: photoReference.recordID) { (record, error) in
                if let error = error {
                    print("Error fetching record from cloudkit: \(error), \(error.localizedDescription)")
                    dispatchGroup.leave()
                }
                
                guard let record = record,
                    let photo = Photo(ckRecord: record) else { completion(false); return }
                
                self.collectionViewPhotos.append(photo)
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: .main) {
            self.collectionViewPhotos.sort(by: { $0.timestamp < $1.timestamp })
            completion(true)
        }
    }
}
