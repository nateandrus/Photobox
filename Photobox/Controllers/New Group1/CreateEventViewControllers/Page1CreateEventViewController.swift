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
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var selectThumbnailImageButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    // MARK: - Properties
    var selectedTextField: UITextField?
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.delegate = self
        locationTextField.delegate = self

        formatKeyboard()
    }
    
    func formatKeyboard() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { (notification) in
            guard let userInfo = notification.userInfo,
                let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
            
            self.bottomConstraint.constant += keyboardFrame.height + 50
            self.view.layoutSubviews()
            
            let amountToOffset = (self.view.frame.height * 0.9) - self.stackView.frame.height - keyboardFrame.height
            print(amountToOffset)
            
            let offSetPoint = CGPoint(x: self.contentView.frame.origin.x, y: self.view.bounds.origin.y + amountToOffset)
            
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
            
            if thumbnailImageView.image == nil {
                destination?.image = #imageLiteral(resourceName: "calendar icon")
            } else {
                destination?.image = thumbnailImageView.image
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
