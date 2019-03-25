//
//  ImageViewController.swift
//  Photobox
//
//  Created by Nathan Andrus on 3/22/19.
//  Copyright © 2019 Nathan Andrus. All rights reserved.
//

import UIKit
import CloudKit

class ImageViewController: UIViewController {

    @IBOutlet weak var eventImageDetailView: UIImageView!
    
    var photoLanding: Photo? {
        didSet {
            loadViewIfNeeded()
            updateViews()
        }
    }
    
    var isFirstIndex: Bool? {
        didSet {
            self.navigationItem.setRightBarButton(nil, animated: false)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadViewIfNeeded()
    }
        
    @IBAction func deleteImageButtonTapped(_ sender: UIBarButtonItem) {
        guard let photo = photoLanding else { return }
        PhotoController.shared.deletePhoto(photo: photo) { (success) in
            if success {
                print("Success deleting from cloudkit and locally")
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    
    func updateViews() {
        guard let photo = photoLanding else { return }
        eventImageDetailView.image = photo.image
    }
}
