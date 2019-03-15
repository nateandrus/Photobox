//
//  CreateEventPage1ViewController.swift
//  Photobox
//
//  Created by Brayden Harris on 3/11/19.
//  Copyright © 2019 Nathan Andrus. All rights reserved.
//

import UIKit

class Page1CreateEventViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var eventThumbnailImageView: UIImageView!
    @IBOutlet weak var selectImageButtonLabel: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    // MARK: - Properties
    var selectedTextField: UITextField?
    
    var selectedImage: UIImage?
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.delegate = self
        locationTextField.delegate = self
        formatKeyboard()
    }
    
    //MARK: - View Lifecycle Methods
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        eventThumbnailImageView.image = nil
        selectImageButtonLabel.setTitle("Select Photo", for: .normal)
    }

    
    @IBAction func selectImageButtonTapped(_ sender: UIButton) {
        presentImagePickerActionSheet()
    }
    
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        self.tabBarController?.selectedIndex = 0
    }
    
    func formatKeyboard() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { (notification) in
            guard let userInfo = notification.userInfo,
                let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
            
            self.bottomConstraint.constant += keyboardFrame.height + 50
            self.view.layoutSubviews()
            
//            let amountToOffset = (self.view.frame.height * 0.9) - self.stackView.frame.height - keyboardFrame.height
//            print(amountToOffset)
            
            let frameInContentView = self.nameLabel.convert(self.nameLabel.bounds, to: self.contentView)
            
            let offSetPoint = CGPoint(x: self.contentView.frame.origin.x, y: frameInContentView.origin.y - frameInContentView.height - 10)
            
            self.scrollView.setContentOffset(offSetPoint, animated: true)
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { (notification) in
            self.bottomConstraint.constant = 0
        }
    }
    
    // MARK: - Navigation
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        guard let name = nameTextField.text,
            let location = locationTextField.text else { return false }
        
        if name.isEmpty {
            nameTextField.layer.borderColor = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)
            return false
        }
        if location.isEmpty {
            locationTextField.layer.borderColor = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)
            return false
        }
        
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPage2" {
            guard let name = nameTextField.text, !name.isEmpty,
                let location = locationTextField.text, !location.isEmpty else { return }
            let destination = segue.destination as? Page2CreateEventViewController
            destination?.name = name
            destination?.location = location
            if eventThumbnailImageView.image == nil {
                destination?.image = #imageLiteral(resourceName: "calendar icon")
            } else {
                destination?.image = eventThumbnailImageView.image
            }
        }
    }
}

extension Page1CreateEventViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        selectedTextField = textField
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

//MARK: - UIImagePickerDelegate
extension Page1CreateEventViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let photo = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            selectImageButtonLabel.setTitle("", for: .normal)
            eventThumbnailImageView.image = photo
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





