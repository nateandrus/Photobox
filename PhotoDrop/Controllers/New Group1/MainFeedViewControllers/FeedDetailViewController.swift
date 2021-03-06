//
//  FeedDetailViewController.swift
//  Photobox
//
//  Created by Nathan Andrus on 3/11/19.
//  Copyright © 2019 Nathan Andrus. All rights reserved.
//

import UIKit
import CloudKit

class FeedDetailViewController: UIViewController {
    
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var eventLocationLabel: UILabel!
    @IBOutlet weak var dateAndTimeLabel: UILabel!
    @IBOutlet weak var endDateandTimeLabel: UILabel!
    @IBOutlet weak var numberOfAttendeesLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var addButtonOutlet: UIButton!
    
    var selectedImage: UIImage? {
        didSet {
            guard let event = eventLandingPad,
                let selectedImage = selectedImage,
                let user = UserController.shared.loggedInUser else { return }
            let userReference = CKRecord.Reference(recordID: user.ckRecord, action: .none)
            let eventReference = CKRecord.Reference(recordID: event.ckrecordID, action: .none)
            PhotoController.shared.addPhoto(toEvent: eventReference, withImage: selectedImage, userReference: userReference, timestamp: Date()) { (_) in
                print("success saving to cloud")
                DispatchQueue.main.async {
                    self.photoCollectionView.reloadData()
                }
            }
        }
    }
    
    var eventLandingPad: Event? {
        didSet {
            loadViewIfNeeded()
            updateViews()
        }
    }
    
    var isFutureEvent: Bool? {
        didSet {
            addButtonOutlet.isHidden = true
        }
    }
    
    var performingSegue = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
        
        guard let event = eventLandingPad else { return }
        PhotoController.shared.fetchCollectionViewPhotos(event: event) { (success) in
            if success {
                DispatchQueue.main.async {
                    self.photoCollectionView.reloadData()
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        performingSegue = false
        self.photoCollectionView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if !performingSegue {
            DispatchQueue.main.async {
                self.navigationController?.popToRootViewController(animated: false)
            }
        }
    }
    
    @IBAction func addPhotoButtonTapped(_ sender: UIButton) {
        performingSegue = true
        presentImagePickerActionSheet()
    }
    
    // MARK: - Navigation
    func updateViews() {
        guard let event = eventLandingPad else { return }
        eventImageView.image = event.eventImage
        eventTitleLabel.text = event.eventTitle
        eventLocationLabel.text = event.location
        dateAndTimeLabel.text = "Start: \(event.startTime.stringWith(dateStyle: .medium, timeStyle: .short))"
        endDateandTimeLabel.text = "End: \(event.endTime.stringWith(dateStyle: .medium, timeStyle: .short))"
        numberOfAttendeesLabel.text = "Number of attendees: \(event.attendees.count)"
        descriptionLabel.text = event.description
        self.title = event.eventTitle
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toLeaveEvent" {
            guard let event = eventLandingPad else { return }
            performingSegue = true
            let destination = segue.destination as? AttendeeEditViewController
            destination?.eventLandingPad = event
        }
        if segue.identifier == "toImageView" {
            guard let event = eventLandingPad else { return }
            let eventPhoto = PhotoController.shared.collectionViewPhotos
            if let imageIndex = photoCollectionView.indexPathsForSelectedItems?.first {
                if let destinationVC = segue.destination as? ImageViewController {
                    performingSegue = true
                    let photoToSend = eventPhoto[imageIndex.row]
                    destinationVC.photoLanding = photoToSend
                    destinationVC.eventLanding = event
                    if imageIndex.row == 0 {
                        destinationVC.isFirstIndex = true
                    }
                }
            }
        }
    }
}

extension FeedDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
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
extension FeedDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
        actionSheet.popoverPresentationController?.sourceView = self.view
        actionSheet.popoverPresentationController?.sourceRect = CGRect(x: 50, y: self.view.frame.height - 100, width: self.view.frame.width - 100, height: 100)
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
