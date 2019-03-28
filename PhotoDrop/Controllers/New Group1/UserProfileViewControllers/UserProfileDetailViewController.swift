//
//  UserProfileDetailViewController.swift
//  Photobox
//
//  Created by Nathan Andrus on 3/12/19.
//  Copyright © 2019 Nathan Andrus. All rights reserved.
//

import UIKit
import CloudKit

class UserProfileDetailViewController: UIViewController {
    
    var pastEventLanding: Event? {
        didSet {
            loadViewIfNeeded()
            updateViews()
        }
    }
    
    var selectedImage: UIImage? {
        didSet {
            guard let event = pastEventLanding,
                let selectedImage = selectedImage,
                let user = UserController.shared.loggedInUser else { return }
            let userReference = CKRecord.Reference(recordID: user.ckRecord, action: .deleteSelf)
            let eventReference = CKRecord.Reference(recordID: event.ckrecordID, action: .deleteSelf)
            PhotoController.shared.addPhoto(toEvent: eventReference, withImage: selectedImage, userReference: userReference, timestamp: Date()) { (_) in
                print("success saving to cloud")
                DispatchQueue.main.async {
                    self.eventImagesCollectionView.reloadData()
                }
            }
        }
    }
    
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var eventLocationLabel: UILabel!
    @IBOutlet weak var dateAndTimeLabel: UILabel!
    @IBOutlet weak var numberOfAttendeesLabel: UILabel!
    @IBOutlet weak var eventImagesCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eventImagesCollectionView.delegate = self
        eventImagesCollectionView.dataSource = self
        
        guard let event = pastEventLanding else { return }
        PhotoController.shared.fetchCollectionViewPhotos(event: event) { (success) in
            if success {
                DispatchQueue.main.async {
                    self.eventImagesCollectionView.reloadData()
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.eventImagesCollectionView.reloadData()
    }
    
    @IBAction func deleteEventButtonTapped(_ sender: UIBarButtonItem) {
        alertController()
    }
    
    
    @IBAction func addPhotoButtonTapped(_ sender: UIButton) {
        presentImagePickerActionSheet()
    }
    
    
    func updateViews() {
        guard let pastEvent = pastEventLanding else { return }
        eventImageView.image = pastEvent.eventImage
        eventTitleLabel.text = pastEvent.eventTitle
        eventLocationLabel.text = pastEvent.location
        dateAndTimeLabel.text = "Ended: \(pastEvent.endTime.stringWith(dateStyle: .medium, timeStyle: .none))"
        numberOfAttendeesLabel.text = "Number of attendees: \(pastEvent.attendees.count)"
        self.title = pastEvent.eventTitle
    }
    
    
     // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let eventPhotos = PhotoController.shared.collectionViewPhotos 
        if segue.identifier == "toPhotoView" {
            if let photoIndex = eventImagesCollectionView.indexPathsForSelectedItems?.first {
                if let destinationVC = segue.destination as? ImageViewViewController {
                    let photoToSend = eventPhotos[photoIndex.row]
                    destinationVC.photoLanding = photoToSend
                    if photoIndex.row == 0 {
                        destinationVC.isFirstThumbnailImage = true
                    }
                }
            }
        }
     }
    
    func alertController() {
        let alertController = UIAlertController(title: "Leave event?", message: "By leaving the event you will no longer have access to the event photos.", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let leaveEventAction = UIAlertAction(title: "Leave", style: .destructive) { (_) in
            guard let user = UserController.shared.loggedInUser, let event = self.pastEventLanding else { return }
            let reference = CKRecord.Reference(recordID: user.ckRecord, action: .deleteSelf)
            EventController.shared.removeAttendee(creatorReference: reference, fromEvent: event, completion: { (success) in
                if success {
                    guard let index = EventController.shared.pastEvents.firstIndex(of: event) else { return }
                    EventController.shared.pastEvents.remove(at: index)
                    self.navigationController?.popViewController(animated: true)
                }
            })
        }
        alertController.addAction(cancelAction)
        alertController.addAction(leaveEventAction)
        present(alertController, animated: true, completion: nil)
    }
}

extension UserProfileDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return PhotoController.shared.collectionViewPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath)
        let photo = PhotoController.shared.collectionViewPhotos[indexPath.row]
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.image = photo.image
        cell.backgroundView = imageView
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing = CGFloat(3)
        return CGSize(width: (collectionView.frame.width / 3) - spacing, height: (collectionView.frame.width / 3) - spacing)
    }
}

//MARK: - UIImagePickerDelegate
extension UserProfileDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let photo = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            selectedImage = photo
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func presentImagePickerActionSheet() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        let actionSheet = UIAlertController(title: "Select a Photo", message: nil, preferredStyle: .actionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            actionSheet.addAction(UIAlertAction(title: "Photos", style: .default, handler: { (_) in
                imagePickerController.sourceType = UIImagePickerController.SourceType.photoLibrary
                self.present(imagePickerController, animated: true, completion: nil)
            }))
        }
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (_) in
                imagePickerController.sourceType = UIImagePickerController.SourceType.camera
                self.present(imagePickerController, animated: true, completion: nil)
            }))
        }
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actionSheet, animated: true)
    }
}
