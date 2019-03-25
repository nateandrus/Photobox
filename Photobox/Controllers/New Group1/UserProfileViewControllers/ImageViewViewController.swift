//
//  ImageViewViewController.swift
//  Photobox
//
//  Created by Nathan Andrus on 3/25/19.
//  Copyright © 2019 Nathan Andrus. All rights reserved.
//

import UIKit

class ImageViewViewController: UIViewController {
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    var photoLanding: Photo? {
        didSet {
            loadViewIfNeeded()
            updateViews()
        }
    }
    
    var isFirstThumbnailImage: Bool? {
        didSet {
            self.navigationItem.setRightBarButton(nil, animated: false)

        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadViewIfNeeded()
    }
    
    func updateViews() {
        guard let photo = photoLanding else { return }
        photoImageView.image = photo.image
    }
    
    @IBAction func deleteImageButtonTapped(_ sender: UIBarButtonItem) {
        guard let photo = photoLanding else { return }
        
        
        PhotoController.shared.deletePhoto(photo: photo) { (success) in
            if success {
                print("Success deleting photo")
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}
