//
//  LogInViewController.swift
//  Photobox
//
//  Created by Brayden Harris on 3/14/19.
//  Copyright © 2019 Nathan Andrus. All rights reserved.
//

import UIKit
import Contacts

class LogInViewController: UIViewController {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        formatKeyboard()
    }
    
    func formatKeyboard() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { (notification) in
            guard let userInfo = notification.userInfo,
                let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
            
            self.bottomConstraint.constant += keyboardFrame.height
            self.view.layoutSubviews()
            
            let frameInContentView = self.usernameLabel.convert(self.usernameLabel.bounds, to: self.contentView)
            
            let offSetPoint = CGPoint(x: self.contentView.frame.origin.x, y: frameInContentView.origin.y - frameInContentView.height)
            
            self.scrollView.setContentOffset(offSetPoint, animated: true)
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { (notification) in
            self.bottomConstraint.constant = 0
        }
    }
    
    @IBAction func logInButtonTapped(_ sender: Any) {
        guard let username = usernameTextField.text else { return }
        let predicate = NSPredicate(format: "%K == %@", argumentArray: [User.usernameKey, username])
        
        CloudKitManager.shared.fetchRecordsWithType(User.typeKey, predicate: predicate, recordFetchedBlock: nil) { (records, error) in
            if let error = error {
                print("Error fetching \(username) from cloudkit: \(error), \(error.localizedDescription)")
                return
            }
            guard let records = records else { return }
            
            if records.count > 1 {
                print("ERROR: Multiple users with name: \(username)")
                return
            }
            
            guard let user = User(record: records.first!) else { return }
            DispatchQueue.main.async {
                if self.passwordTextField.text == user.password {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "MasterTabBarController")
                    self.present(vc, animated: true)
                } else {
                    self.passwordTextField.layer.borderWidth = 2
                    self.passwordTextField.layer.cornerRadius = 5
                    self.passwordTextField.layer.borderColor = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)
                }
            }
        }
    }
}
extension LogInViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
