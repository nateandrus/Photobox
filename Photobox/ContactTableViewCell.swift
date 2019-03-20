//
//  ContactTableViewCell.swift
//  Photobox
//
//  Created by Brayden Harris on 3/12/19.
//  Copyright © 2019 Nathan Andrus. All rights reserved.
//

import UIKit
import CloudKit
import Contacts

class ContactTableViewCell: UITableViewCell {

    // MARK: - Landing pads
    var contact: CNContact? {
        didSet {
            updateViews()
        }
    }
    var user: User? {
        didSet {
            updateViews()
        }
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    // MARK: - IBActions
    @IBAction func addButtonTapped(_ sender: Any) {
        // If the cell is a contact
        if contact != nil {
            guard let contact = contact else { return }
            
            // Check to see if the contact is already a user
            for phoneNumber in contact.phoneNumbers {
                let stringPhoneNumber = phoneNumber.value.stringValue.components(separatedBy: NSCharacterSet.decimalDigits.inverted).joined()
                
                let filteredUsers = UserController.shared.users.filter { (user) -> Bool in
                    return user.phoneNumber == stringPhoneNumber
                }
                
                // If the contact is already a user
                if filteredUsers.count > 0 {
                    guard let recordID = filteredUsers.first?.ckRecord else { return }
                    
                    let reference = CKRecord.Reference(recordID: recordID, action: .none)
                    
                    Page3CreateEventViewController.shared.invitedUsers.append(reference)
                }
                // If the contact isn't a user
                else {
                    let phoneNumbersCount = contact.phoneNumbers.count
                    if phoneNumbersCount > 1 {
                        let alertController = UIAlertController(title: "Send invitation to join your event", message: "Which phone number would you like to send the invitation to?", preferredStyle: .actionSheet)
                        var actions: [UIAlertAction] = []
                        for num in 1...phoneNumbersCount {
                            let actionName =
                                actions.append(UIAlertAction(title: "PhoneNumber\(num)", style: .default, handler: { (actionTapped) in
                                    <#code#>
                                }))
                        }
                    }
                }
            }
        }
        
    }
    
    func updateViews() {

        if contact != nil {
            guard let contact = contact else { return }
            nameLabel.text = contact.givenName + " " + contact.familyName
            usernameLabel.text = contact.givenName
        } else if user != nil {
            guard let user = user,
            let username = user.username else { return }
            nameLabel.text = "@\(username)"
            usernameLabel.text = ""
        }
//        CloudKitManager.shared.fetchDiscoverableUserWith(recordID: user.ckRecord) { (userID) in
//            guard let userID = userID else { return }
//            guard let firstName = userID.nameComponents?.givenName else { return }
//            guard let lastName = userID.nameComponents?.familyName else { return }
//            DispatchQueue.main.async {
//                self.nameLabel.text = "\(firstName) \(lastName)"
//            }
//        }
        addButton.layer.cornerRadius = addButton.frame.width / 2
    }
}
