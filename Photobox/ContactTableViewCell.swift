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
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    @IBAction func addButtonTapped(_ sender: Any) {
        //Send invitation to the contact
    }
    
    func updateViews() {
        guard let user = user else { return }
        
        CloudKitManager.shared.fetchDiscoverableUserWith(recordID: user.ckRecord) { (userID) in
            guard let userID = userID else { return }
            
            guard let firstName = userID.nameComponents?.givenName else { return }
            guard let lastName = userID.nameComponents?.familyName else { return }
            
            DispatchQueue.main.async {
                self.nameLabel.text = "\(firstName) \(lastName)"
            }
        
        }
        
        
        addButton.layer.cornerRadius = addButton.frame.width / 2
    }
    
}
