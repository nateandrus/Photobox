//
//  ContactTableViewCell.swift
//  Photobox
//
//  Created by Brayden Harris on 3/12/19.
//  Copyright © 2019 Nathan Andrus. All rights reserved.
//

import UIKit

class ContactTableViewCell: UITableViewCell {

    var contact: String? {
        didSet {
            updateViews()
        }
    }
    
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    func updateViews() {
        guard let contact = contact else { return }
        DispatchQueue.main.async {
            
        }
    }
    
}
