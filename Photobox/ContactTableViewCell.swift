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

protocol ContactTableViewCellDelegate: class {
    func addButtonTapped(_ cell: ContactTableViewCell, contact: CNContact?, user: User?, completion: @escaping (Bool) -> Void)
}

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
    
    // MARK: - weak var optional delegate
    weak var delegate: ContactTableViewCellDelegate?
    
    // MARK: - IBActions
    @IBAction func addButtonTapped(_ sender: Any) {
        delegate?.addButtonTapped(self, contact: contact, user: user, completion: { (didAdd) in
            if didAdd {
                self.addButton.setTitle("✓", for: .normal)
                self.updateViews()
            }
        })
    }
    
    func updateViews() {

        if contact != nil {
            guard let contact = contact else { return }
            nameLabel.text = contact.givenName + " " + contact.familyName
            usernameLabel.text = contact.phoneNumbers.first?.value.stringValue
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
    }
}
