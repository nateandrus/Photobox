//
//  SignUpViewController.swift
//  Photobox
//
//  Created by Brayden Harris on 3/14/19.
//  Copyright © 2019 Nathan Andrus. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var usernameErrorLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordErrorLabel: UILabel!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
            
            UserController.shared.saveUserWith(username: username, password: password, profilePic: #imageLiteral(resourceName: "default user icon"), phoneNumber: nil, completion: { (success) in
                if success {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "PhoneNumberViewController")
                    self.present(vc, animated: true)
                }
            })
        }
    }

    @IBAction func logInButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LogInScreen")
        self.present(vc, animated: true)
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    

}
