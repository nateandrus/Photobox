//
//  UserProfileViewController.swift
//  Photobox
//
//  Created by Nathan Andrus on 3/12/19.
//  Copyright © 2019 Nathan Andrus. All rights reserved.
//

import UIKit

class UserProfileViewController: UIViewController {

    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var pastEventsTableView: UITableView!
    
    var selectedImage: UIImage? {
        didSet {
            guard let newProfilePic = selectedImage, let user = UserController.shared.loggedInUser else { return }
            userProfileImageView.image = newProfilePic
            UserController.shared.modify(user: user, withUsername: nil, password: nil, profileImage: newProfilePic, invitedEvents: nil) { (success) in
                if success {
                    print("success changing profile pic")
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadViewIfNeeded()
        updateViews()
        self.pastEventsTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userProfileImageView.layoutIfNeeded()
        userProfileImageView.layer.masksToBounds = true
        userProfileImageView.layer.cornerRadius = (userProfileImageView.frame.width / 2)
        
        loadViewIfNeeded()
        pastEventsTableView.delegate = self
        pastEventsTableView.dataSource = self
    }
    
    @IBAction func changeUserProfileImage(_ sender: UIButton) {
        presentImagePickerActionSheet()
    }
    
    
    func updateViews() {
        userProfileImageView.image = UserController.shared.loggedInUser?.profileImage
        usernameLabel.text = UserController.shared.loggedInUser?.username
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEventPhotoVC" {
            if let eventIndex = pastEventsTableView.indexPathForSelectedRow {
                if let destinationVC = segue.destination as? UserProfileDetailViewController {
                    let eventToSend = EventController.shared.pastEvents[eventIndex.row]
                    destinationVC.pastEventLanding = eventToSend
                }
            }
        }
    }
}

extension UserProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return EventController.shared.pastEvents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pastEventCell", for: indexPath) as? EventTableViewCell
        let event = EventController.shared.pastEvents[indexPath.row]
        cell?.eventCellLanding = event
        return cell ?? UITableViewCell()
    }
}

//MARK: - UIImagePickerDelegate
extension UserProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
            actionSheet.popoverPresentationController?.sourceView = self.view
            actionSheet.popoverPresentationController?.sourceRect = CGRect(x: 50, y: self.view.frame.height - 100, width: self.view.frame.width - 100, height: 100)
            actionSheet.addAction(UIAlertAction(title: "Photos", style: .default, handler: { (_) in
                imagePickerController.sourceType = UIImagePickerController.SourceType.photoLibrary
                self.present(imagePickerController, animated: true, completion: nil)
            }))
        }
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            actionSheet.popoverPresentationController?.sourceView = self.view
            actionSheet.popoverPresentationController?.sourceRect = CGRect(x: 50, y: self.view.frame.height - 100, width: self.view.frame.width - 100, height: 100)
            actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (_) in
                imagePickerController.sourceType = UIImagePickerController.SourceType.camera
                self.present(imagePickerController, animated: true, completion: nil)
            }))
        }
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actionSheet, animated: true)
    }
}
