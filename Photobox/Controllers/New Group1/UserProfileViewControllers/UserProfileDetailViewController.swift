//
//  UserProfileDetailViewController.swift
//  Photobox
//
//  Created by Nathan Andrus on 3/12/19.
//  Copyright © 2019 Nathan Andrus. All rights reserved.
//

import UIKit

class UserProfileDetailViewController: UIViewController {
    
    var pastEventLanding: Event? {
        didSet {
            loadViewIfNeeded()
            updateViews()
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
    }
    
    func updateViews() {
        guard let pastEvent = pastEventLanding else { return }
        eventImageView.image = pastEvent.eventImage
        eventTitleLabel.text = pastEvent.eventTitle
        eventLocationLabel.text = pastEvent.location
        dateAndTimeLabel.text = "Ended: \(pastEvent.endTime.stringWith(dateStyle: .medium, timeStyle: .short))"
        numberOfAttendeesLabel.text = "Number of attendees: \(pastEvent.attendees.count)"
        self.title = pastEvent.eventTitle
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
