//
//  InvitationsListTableViewController.swift
//  Photobox
//
//  Created by Brayden Harris on 3/13/19.
//  Copyright © 2019 Nathan Andrus. All rights reserved.
//

import UIKit
import CloudKit

class InvitationsListTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let invitedEvents = UserController.shared.loggedInUser?.invitedEvents else { return 0 }
        return invitedEvents.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "invitationCell", for: indexPath) as? InvitationTableViewCell
        
        cell?.eventReference = UserController.shared.loggedInUser?.invitedEvents[indexPath.row]

        return cell ?? UITableViewCell()
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailVC" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let destinationVC = segue.destination as? InvitationDetailViewController
            destinationVC?.invitedEventReference = UserController.shared.loggedInUser?.invitedEvents[indexPath.row]
        }
    }
}
