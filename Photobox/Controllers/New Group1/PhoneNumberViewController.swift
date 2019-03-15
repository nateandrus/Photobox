//
//  PhoneNumberViewController.swift
//  Photobox
//
//  Created by Brayden Harris on 3/14/19.
//  Copyright © 2019 Nathan Andrus. All rights reserved.
//

import UIKit
import Contacts

class PhoneNumberViewController: UIViewController {

    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    var username: String?
    var password: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func OKButtonTapped(_ sender: Any) {
        guard let username = username,
            let password = password,
            let phoneNumber = phoneNumberTextField.text, !phoneNumber.isEmpty else { return }
        
        UserController.shared.fetchUserWith(phoneNumber: phoneNumber) { (user) in
            if user != nil {
                DispatchQueue.main.async {
                    self.errorLabel.text = "A user already exists with this phone number."
                }
                return
            }
        }
        
        UserController.shared.saveUserWith(username: username, password: password, phoneNumber: phoneNumber) { (success) in
            if success {
                DispatchQueue.main.async {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "MasterTabBarController")
                    self.present(vc, animated: true)
                }
            }
        }
    }

}
