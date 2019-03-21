//
//  InvitationTableViewCell.swift
//  Photobox
//
//  Created by Brayden Harris on 3/21/19.
//  Copyright © 2019 Nathan Andrus. All rights reserved.
//

import UIKit
import CloudKit

class InvitationTableViewCell: UITableViewCell {

    // MARK: - IBOutlets
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    
    // Landing Pad
    var eventReference: CKRecord.Reference? {
        didSet{
            guard let eventReference = eventReference else { return }
            
            let recordID = eventReference.recordID
            
            let record = CKRecord(recordType: Event.typeKey, recordID: recordID)
            
            guard let event = Event(record: record) else { return }
            
            self.event = event
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
            self.locationLabel.text = "Location: \(event.location)"
            self.startDateLabel.text = event.startTime.stringWith(dateStyle: .medium, timeStyle: .short)
        }
    }

    // MARK: - IBActions
    @IBAction func acceptButtonTapped(_ sender: Any) {
        guard let eventReference = eventReference,
            let eventIndex = UserController.shared.loggedInUser?.invitedEvents.index(of: eventReference),
            let loggedInUser = UserController.shared.loggedInUser else { return }
        
        let recordID = eventReference.recordID
        
        let record = CKRecord(recordType: Event.typeKey, recordID: recordID)
        
        guard let event = Event(record: record) else { return }
        
        UserController.shared.events.append(event)
        
        loggedInUser.invitedEvents.remove(at: eventIndex)
    }
    
    @IBAction func declineButtonTapped(_ sender: Any) {
        guard let eventReference = eventReference,
            let eventIndex = UserController.shared.loggedInUser?.invitedEvents.index(of: eventReference),
            let loggedInUser = UserController.shared.loggedInUser else { return }
        
        loggedInUser.invitedEvents.remove(at: eventIndex)
    }
}
