//
//  LoadingViewController.swift
//  Photobox
//
//  Created by Brayden Harris on 3/26/19.
//  Copyright © 2019 Nathan Andrus. All rights reserved.
//

import UIKit
import CloudKit

class LoadingViewController: UIViewController {

    var invites: [CKRecord.Reference]?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UserController.shared.fetchLoggedInUser { (didFetch) in
            if didFetch {
                guard let invites = UserController.shared.loggedInUser?.invitedEvents else { return }
                
                self.invites = invites
                
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "toInvitationsList", sender: self)
                }
            }
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toInvitationsList" {
            let destinationVC = segue.destination as? InvitationsListTableViewController
            destinationVC?.invites = self.invites
        }
    }

}
