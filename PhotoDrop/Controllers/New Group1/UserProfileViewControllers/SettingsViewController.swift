//
//  SettingsViewController.swift
//  Photobox
//
//  Created by Nathan Andrus on 3/22/19.
//  Copyright © 2019 Nathan Andrus. All rights reserved.
//

import UIKit
import UserNotifications

class SettingsViewController: UIViewController {

    @IBOutlet weak var notificationsSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        UNUserNotificationCenter.current().
    }
    
    @IBAction func changeUsernameButtonTapped(_ sender: UIButton) {
        changeUsernameAlertController()
    }
    
    @IBAction func deleteAccountButtonTapped(_ sender: UIButton) {
        deleteAccountAlertController()
    }
    
    @IBAction func switchToggled(_ sender: Any) {
        
    }
    
    func changeUsernameAlertController() {
        var usernameTextField: UITextField?
        let alertController = UIAlertController(title: "Change Username", message: nil, preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter new username..."
            usernameTextField = textField
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let changeUsernameAction = UIAlertAction(title: "Change", style: .default) { (_) in
            guard let newUsername = usernameTextField?.text, !newUsername.isEmpty, let user = UserController.shared.loggedInUser else { return }
            UserController.shared.modify(user: user, withUsername: newUsername, password: nil, profileImage: nil, invitedEvents: nil, completion: { (success) in
                if success {
                    self.navigationController?.popViewController(animated: true)
                }
            })
        }
        alertController.addAction(cancelAction)
        alertController.addAction(changeUsernameAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func deleteAccountAlertController() {
        let alertController = UIAlertController(title: "Delete Account", message: "Are you sure you want to delete account?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (_) in
            guard let user = UserController.shared.loggedInUser else { return }
            UserController.shared.delete(user: user) { (success) in
                if success {
                    print("User has been deleted")
                    DispatchQueue.main.async {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let vc = storyboard.instantiateViewController(withIdentifier: "LogInScreen")
                        self.present(vc, animated: true)
                    }
                }
            }
        }
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        present(alertController, animated: true, completion: nil)
    }
}
