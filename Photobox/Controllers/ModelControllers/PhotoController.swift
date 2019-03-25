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
            
            let photoReference = CKRecord.Reference(record: record, action: .none)
            
            CloudKitManager.shared.fetchRecord(withID: event.recordID, completion: { (record, error) in
                if let error = error {
                    print("Error fetching event record from cloudkit: \(error.localizedDescription)")
                    completion(false)
                    return
                }
                guard let record = record,
                    let event = Event(record: record) else { completion(false); return }
                
                
                event.eventPhotos?.append(photoReference)
                
                EventController.shared.modify(event: event, withTitle: nil, image: nil, location: nil, startTime: nil, endTime: nil, description: nil, invitedUsers: nil, eventPhotos: event.eventPhotos, attendees: nil)
                
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
                    let photo = Photo(ckRecord: record),
                    let user = UserController.shared.loggedInUser else { completion(false); return }
                
                let reference = CKRecord.Reference(recordID: user.ckRecord, action: .none)
                
                var usersThatReported: [CKRecord.Reference] = []
                
                if photo.usersThatReported != nil {
                    usersThatReported = photo.usersThatReported!
                }
                
                if !usersThatReported.contains(reference) {
                    self.collectionViewPhotos.append(photo)
                }
                
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: .main) {
            self.collectionViewPhotos.sort(by: { $0.timestamp < $1.timestamp })
            completion(true)
        }
    }
    
    func deletePhoto(photo: Photo, completion: @escaping (Bool) -> Void) {
        guard let user = UserController.shared.loggedInUser else { return }
        let userReference = CKRecord.Reference(recordID: user.ckRecord, action: .none)
        if photo.userReference == userReference {
            // Delete Locally
            guard let indexOfPhoto = collectionViewPhotos.firstIndex(of: photo) else { return }
            collectionViewPhotos.remove(at: indexOfPhoto)
            //Delete in cloud
            let photoRecord = photo.photoRecordID
            CloudKitManager.shared.deleteRecordWithID(photoRecord) { (record, error) in
                if let error = error {
                    print("Error deleting photo: \(error) :: \(error.localizedDescription)")
                    completion(false)
                    return
                }
            }
            completion(true)
        } else {
            print("user references don't match")
        }
    }
    
    func modifyPhoto(photo: Photo, numberOfTimesReported: Int?, usersThatReported: [CKRecord.Reference]?, completion: @escaping (Bool) -> Void) {
        if numberOfTimesReported != nil {
            photo.numberOfTimesReported = numberOfTimesReported!
        }
        if usersThatReported != nil {
            photo.usersThatReported = usersThatReported!
        }
        
        guard let record = CKRecord(photo: photo) else { completion(false); return }
        
        CloudKitManager.shared.modifyRecords([record], perRecordCompletion: nil) { (_, error) in
            if let error = error {
                print("Error modifying photo: \(error), \(error.localizedDescription)")
                completion(false)
                return
            }
            
            completion(true)
        }
    }
}
