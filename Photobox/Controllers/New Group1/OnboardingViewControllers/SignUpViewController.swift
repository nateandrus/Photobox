//
//  SignUpViewController.swift
//  Photobox
//
//  Created by Brayden Harris on 3/14/19.
//  Copyright © 2019 Nathan Andrus. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var usernameErrorLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordErrorLabel: UILabel!
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
    
    @IBAction func signUpButtonTapped(_ sender: Any) {
        guard let username = usernameTextField.text, !username.isEmpty,
        let password = passwordTextField.text, !password.isEmpty,
            let confirmPassword = confirmPasswordTextField.text else { return }
        
        let predicate = NSPredicate(format: "%K == %@", argumentArray: [User.usernameKey, username])
        CloudKitManager.shared.fetchRecordsWithType(User.typeKey, predicate: predicate, recordFetchedBlock: nil) { (records, error) in
            if let error = error {
                print("Error fetching user records: \(error), \(error.localizedDescription)")
            }
            
            guard let records = records else { return }
            
            if records.count > 0 {
                DispatchQueue.main.async {
                    self.usernameTextField.layer.borderWidth = 2
                    self.usernameTextField.layer.cornerRadius = 4
                    self.usernameTextField.layer.borderColor = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)
                    self.usernameErrorLabel.text = "Username already taken. Enter new username..."
                }
                return
            }
            
            if password != confirmPassword {
                DispatchQueue.main.async {
                    self.passwordTextField.layer.borderWidth = 2
                    self.passwordTextField.layer.cornerRadius = 4
                    self.passwordTextField.layer.borderColor = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)
                    self.confirmPasswordTextField.layer.borderWidth = 2
                    self.confirmPasswordTextField.layer.cornerRadius = 4
                    self.confirmPasswordTextField.layer.borderColor = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)
                    
                    self.passwordErrorLabel.text = "Passwords do not match"
                    self.confirmPasswordErrorLabel.text = "Passwords do not match"
                    return
                }
            } 
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "PhoneNumberViewController") as? PhoneNumberViewController
            guard let phoneNumberVC = vc else { return }
            phoneNumberVC.username = username
            phoneNumberVC.password = password
            DispatchQueue.main.async {
                self.present(phoneNumberVC, animated: true)
            }
        }
    }

    @IBAction func logInButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LogInScreen")
        self.present(vc, animated: true)
    }
}
extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
}

