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
            self.locationLabel.text = event.location
            self.dateLabel.text = "\(event.startTime.stringWith(dateStyle: .medium, timeStyle: .short)) - \(event.endTime.stringWith(dateStyle: .medium, timeStyle: .short))"
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
        
    }
    
    @IBAction func declineButtonTapped(_ sender: Any) {
        
    }
}
