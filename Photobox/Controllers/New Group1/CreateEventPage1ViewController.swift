//
//  CreateEventPage1ViewController.swift
//  Photobox
//
//  Created by Brayden Harris on 3/11/19.
//  Copyright © 2019 Nathan Andrus. All rights reserved.
//

import UIKit

class CreateEventPage1ViewController: UIViewController {

    var heightNeeded: CGFloat?
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var selectThumbnailImageButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var selectedTextField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.delegate = self
        locationTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.view.layoutSubviews()
        scrollView.keyboardDismissMode = .onDrag
        let heightNeeded = thumbnailImageView.frame.height + stackView.frame.height + 15
        print(heightNeeded)
        let safeAreaFrame = view.safeAreaLayoutGuide.layoutFrame
        let viewHeight = safeAreaFrame.height
        print(viewHeight)
        if heightNeeded > viewHeight {
            print("expanded:")
            self.bottomConstraint.constant += heightNeeded - viewHeight + 150
            reloadInputViews()
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { (_) in
            
            self.view.layoutSubviews()
            
            let frameInContentView = self.selectedTextField!.convert(self.selectedTextField!.bounds, to: self.contentView)
            
            let offSetPoint = CGPoint(x: self.contentView.frame.origin.x, y: frameInContentView.origin.y - frameInContentView.height)
            
            self.scrollView.setContentOffset(offSetPoint, animated: true)
        }
    }

    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
 

}
extension CreateEventPage1ViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        selectedTextField = textField
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        //or
        //self.view.endEditing(true)
        return true
    }
}
