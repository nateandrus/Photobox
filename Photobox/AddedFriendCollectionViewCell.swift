//
//  AddedFriendCollectionViewCell.swift
//  Photobox
//
//  Created by Brayden Harris on 3/20/19.
//  Copyright © 2019 Nathan Andrus. All rights reserved.
//

import UIKit
import Contacts
import CloudKit

protocol AddedFriendCollectionViewCellDelegate: class {
    func removeButtonTapped(_ cell: AddedFriendCollectionViewCell, contact: CNContact?, user: User?)
}

class AddedFriendCollectionViewCell: UICollectionViewCell {
    
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
    @IBOutlet weak var removeButton: UIButton!
    
    // Weak var optional delegate
    weak var delegate: AddedFriendCollectionViewCellDelegate?
    
    // MARK: - IBActions
    @IBAction func removeButtonTapped(_ sender: Any) {
        delegate?.removeButtonTapped(self, contact: contact, user: user)
    }
    
    func updateViews() {
        if contact != nil {
            nameLabel.text = contact?.givenName
        } else {
            if let username = user?.username {
                nameLabel.text = "@\(username)"
            } else {
                nameLabel.text = "@"
            }
        }
        removeButton.layer.cornerRadius = removeButton.frame.width / 2
        removeButton.backgroundColor = #colorLiteral(red: 0.8403196383, green: 0.8403196383, blue: 0.8403196383, alpha: 1)
        removeButton.setTitleColor(#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1), for: .normal)
    }
}
