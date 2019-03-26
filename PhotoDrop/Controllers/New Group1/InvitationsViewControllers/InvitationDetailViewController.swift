//
//  InvitationDetailViewController.swift
//  Photobox
//
//  Created by Brayden Harris on 3/21/19.
//  Copyright © 2019 Nathan Andrus. All rights reserved.
//

import UIKit
import CloudKit

class InvitationDetailViewController: UIViewController {
    // Landing Pad
    var invitedEventReference: CKRecord.Reference? {
        didSet {
            guard let eventReference = invitedEventReference else { return }
            
            let recordID = eventReference.recordID
            
            CloudKitManager.shared.fetchRecord(withID: recordID) { (record, error) in
                if let error = error {
                    print("Error fetching record from cloudkit: \(error), \(error.localizedDescription)")
                    return
                }
                guard let record = record,
                    let event = Event(record: record) else { return }
                
                print(event.eventTitle)
                self.event = event
            }
        }
    }
    
    var event: Event? {
        didSet {
            updateViews()
        }
    }
    
    func updateViews() {
        guard let event = event else { return }
        
        DispatchQueue.main.async {
            self.eventImageView.image = event.eventImage
            self.titleLabel.text = event.eventTitle
            self.locationLabel.text = event.location
            self.dateLabel.text = "\(event.startTime.stringWith(dateStyle: .medium, timeStyle: .short)) - \(event.endTime.stringWith(dateStyle: .medium, timeStyle: .short))"
            self.descriptionLabel.text = event.description
        }
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func acceptButtonTapped(_ sender: Any) {
        guard let eventReference = invitedEventReference,
            let event = event,
            var invitedEvents = UserController.shared.loggedInUser?.invitedEvents,
            let eventIndex = invitedEvents.firstIndex(of: eventReference),
            let loggedInUser = UserController.shared.loggedInUser,
            let invitedUsers = event.invitedUsers else { return }
        
        let userRef = CKRecord.Reference(recordID: loggedInUser.ckRecord, action: .none)
        
        // Add the user to the event's attendees list
        event.attendees.append(userRef)
        
        guard let userIndex = invitedUsers.firstIndex(of: userRef) else { return }
        
        UserController.shared.events.append(event)
        EventController.shared.sortByTimeStamp()
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
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func declineButtonTapped(_ sender: Any) {
        guard let eventReference = invitedEventReference,
            let event = event,
            var invitedEvents = UserController.shared.loggedInUser?.invitedEvents,
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
            self.navigationController?.popViewController(animated: true)
        }
    }
}
