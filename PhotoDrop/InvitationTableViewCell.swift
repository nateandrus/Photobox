//
//  InvitationTableViewCell.swift
//  Photobox
//
//  Created by Brayden Harris on 3/21/19.
//  Copyright © 2019 Nathan Andrus. All rights reserved.
//

import UIKit
import CloudKit

protocol InvitationTableViewCellDelegate: class {
    func acceptButtonTapped(_ cell: InvitationTableViewCell, eventReference: CKRecord.Reference?, event: Event?, completion: ((Bool) -> Void)?)
    func declineButtonTapped(_ cell: InvitationTableViewCell, eventReference: CKRecord.Reference?, event: Event?, completion: ((Bool) -> Void)?)
}

class InvitationTableViewCell: UITableViewCell {

    // MARK: - IBOutlets
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var declineButton: UIButton!
    
    // MARK: - weak var optional delegate
    weak var delegate: InvitationTableViewCellDelegate?
    
    // Landing Pad
    var eventReference: CKRecord.Reference? {
        didSet{
            guard let eventReference = eventReference else { return }
            
            let recordID = eventReference.recordID
            
            CloudKitManager.shared.fetchRecord(withID: recordID) { (record, error) in
                if let error = error {
                    print("Error fetching record from cloudkit: \(error), \(error.localizedDescription)")
                    return
                }
                guard let record = record,
                    let event = Event(record: record) else { return }
                
                self.event = event
            }
        }
    }
    
    var event: Event? {
        didSet {
            updateViews()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.text = ""
        locationLabel.text = ""
        startDateLabel.text = ""
        acceptButton.isHidden = true
        declineButton.isHidden = true
    }
    
    func updateViews() {
        guard let event = event else { return }
        
        DispatchQueue.main.async {
            self.eventImageView.image = event.eventImage
            self.titleLabel.text = event.eventTitle
            self.locationLabel.text = "Location: \(event.location)"
            self.startDateLabel.text = event.startTime.stringWith(dateStyle: .medium, timeStyle: .short)
            self.acceptButton.isHidden = false
            self.declineButton.isHidden = false
        }
    }

    // MARK: - IBActions
    @IBAction func acceptButtonTapped(_ sender: Any) {
        delegate?.acceptButtonTapped(self, eventReference: eventReference, event: event, completion: nil)
    }
    
    @IBAction func declineButtonTapped(_ sender: Any) {
        delegate?.declineButtonTapped(self, eventReference: eventReference, event: event, completion: nil)
    }
}
