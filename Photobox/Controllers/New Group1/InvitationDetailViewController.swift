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
            let eventIndex = UserController.shared.loggedInUser?.invitedEvents.index(of: eventReference),
            let loggedInUser = UserController.shared.loggedInUser else { return }
        
        CloudKitManager.shared.fetchRecord(withID: eventReference.recordID) { (record, error) in
            if let error = error {
                print("Error fetching record from Cloud Kit: \(error), \(error.localizedDescription)")
            }
            
            guard let record = record else { return }
            
            guard let event = Event(record: record) else { return }
            
            UserController.shared.events.append(event)
            
            loggedInUser.invitedEvents.remove(at: eventIndex)
        }
    }
    
    @IBAction func declineButtonTapped(_ sender: Any) {
        guard let eventReference = invitedEventReference,
            let eventIndex = UserController.shared.loggedInUser?.invitedEvents.index(of: eventReference),
            let loggedInUser = UserController.shared.loggedInUser else { return }
        
        loggedInUser.invitedEvents.remove(at: eventIndex)
    }
}
