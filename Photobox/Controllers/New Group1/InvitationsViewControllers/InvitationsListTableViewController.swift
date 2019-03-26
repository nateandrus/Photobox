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
    
    // Landing Pad
    var invites: [CKRecord.Reference]? {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UserController.shared.fetchLoggedInUser { (didFetch) in
            if didFetch {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let invitedEvents = invites else { return 0 }
        return invitedEvents.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "invitationCell", for: indexPath) as? InvitationTableViewCell
        
        guard let invitedEvents = invites else { return UITableViewCell() }
        
        cell?.eventReference = invitedEvents[indexPath.row]
        
        //Set delegate to self
        cell?.delegate = self

        return cell ?? UITableViewCell()
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailVC" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let destinationVC = segue.destination as? InvitationDetailViewController
            
            guard let invitedEvents = invites else { return }
            
            destinationVC?.invitedEventReference = invitedEvents[indexPath.row]
        }
    }
}

extension InvitationsListTableViewController: InvitationTableViewCellDelegate {
    
    func acceptButtonTapped(_ cell: InvitationTableViewCell, eventReference: CKRecord.Reference?, event: Event?, completion: ((Bool) -> Void)?) {
        guard let eventReference = eventReference,
            let event = event,
            var invitedEvents = invites,
            let eventIndex = invitedEvents.firstIndex(of: eventReference),
            let loggedInUser = UserController.shared.loggedInUser,
            let invitedUsers = event.invitedUsers else { return }
        
        let userRef = CKRecord.Reference(recordID: loggedInUser.ckRecord, action: .none)
        
        // Add the user to the event's attendees list
        event.attendees.append(userRef)
        
        guard let userIndex = invitedUsers.firstIndex(of: userRef) else { return }
        
        UserController.shared.events.append(event)
        EventController.shared.scheduleUserNotification24HRSBefore(for: event)
        EventController.shared.scheduleUserNotificationForStartTime(for: event)
        
        // Remove the event from the user's invited events
        invitedEvents.remove(at: eventIndex)
        // Remove the user from the event's invited users
        event.invitedUsers?.remove(at: userIndex)
        
        // Update CloudKit
        UserController.shared.modify(user: loggedInUser, withUsername: nil, password: nil, profileImage: nil, invitedEvents: invitedEvents, completion: nil)
        EventController.shared.modify(event: event, withTitle: nil, image: nil, location: nil, startTime: nil, endTime: nil, description: nil, invitedUsers: event.invitedUsers, eventPhotos: nil, attendees: event.attendees)
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func declineButtonTapped(_ cell: InvitationTableViewCell, eventReference: CKRecord.Reference?, event: Event?, completion: ((Bool) -> Void)?) {
        guard let eventReference = eventReference,
            let event = event,
            var invitedEvents = invites,
            let eventIndex = invitedEvents.firstIndex(of: eventReference),
            let loggedInUser = UserController.shared.loggedInUser,
            let invitedUsers = event.invitedUsers else { return } 
        
        let userRef = CKRecord.Reference(recordID: loggedInUser.ckRecord, action: .none)
        
        guard let userIndex = invitedUsers.firstIndex(of: userRef) else { return }
        
        UserController.shared.events.append(event)
        
        // Remove the event from the user's invited events
        invitedEvents.remove(at: eventIndex)
        // Remove the user from the event's invited users
        event.invitedUsers?.remove(at: userIndex)
        
        // Update CloudKit
        UserController.shared.modify(user: loggedInUser, withUsername: nil, password: nil, profileImage: nil, invitedEvents: invitedEvents, completion: nil)
        EventController.shared.modify(event: event, withTitle: nil, image: nil, location: nil, startTime: nil, endTime: nil, description: nil, invitedUsers: event.invitedUsers, eventPhotos: nil, attendees: nil)
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
