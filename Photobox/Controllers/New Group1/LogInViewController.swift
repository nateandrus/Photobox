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

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
            print(user.username)
            print(user.password)
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
