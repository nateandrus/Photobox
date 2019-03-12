//
//  UserProfileDetailViewController.swift
//  Photobox
//
//  Created by Nathan Andrus on 3/12/19.
//  Copyright © 2019 Nathan Andrus. All rights reserved.
//

import UIKit

class UserProfileDetailViewController: UIViewController {
    
    var collectionViewPhotos: [Photo] = []

    var pastEventLanding: Event? {
        didSet {
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
        numberOfAttendeesLabel.text = "Number of attendees: \(pastEvent.attendees)"
    }
}

extension UserProfileDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath)
        let photo = collectionViewPhotos[indexPath.row]
        let photoImageView = UIImageView(frame: cell.frame)
        photoImageView.image = photo.image
        cell.backgroundView = photoImageView
        return cell
    }
}
