//
//  PhoneNumberViewController.swift
//  Photobox
//
//  Created by Brayden Harris on 3/14/19.
//  Copyright © 2019 Nathan Andrus. All rights reserved.
//

import UIKit
import Contacts
import CloudKit

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
            let phoneNumber = phoneNumberTextField.text?.components(separatedBy: NSCharacterSet.decimalDigits.inverted).joined(), !phoneNumber.isEmpty else { return }
        
        UserController.shared.fetchUserWith(phoneNumber: phoneNumber) { (user) in
            if user != nil {
                if user?.username != nil {
                    DispatchQueue.main.async {
                        self.errorLabel.text = "A user already exists with this phone number."
                    }
                } else {
                    user?.username = username
                    user?.password = password
                    
                    CKContainer.default().fetchUserRecordID { (appleUserRecordID, error) in
                        if let error = error {
                            print("Error fetching user's apple ID: \(error.localizedDescription)")
                            return
                        }
                        
                        guard let appleUserRecordID = appleUserRecordID else { return }
                        
                        let reference = CKRecord.Reference(recordID: appleUserRecordID, action: .deleteSelf)
                        
                        user?.creatorReference = reference
                    
                        //Update CloudKit
                        guard let userRecord = CKRecord(user: user!) else { return }
                        
                        CloudKitManager.shared.modifyRecords([userRecord], perRecordCompletion: nil, completion: { (_, error) in
                            if let error = error {
                                print("Error modifying record: \(error), \(error.localizedDescription)")
                            }
                            
                            DispatchQueue.main.async {
                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                let vc = storyboard.instantiateViewController(withIdentifier: "MasterTabBarController")
                                self.present(vc, animated: true)
                            }
                        })
                    }
                }
            } else {
                UserController.shared.saveUserWith(username: username, password: password, phoneNumber: phoneNumber) { (success, _) in
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
    }

}
