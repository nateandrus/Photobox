//
//  EventTableViewCell.swift
//  Photobox
//
//  Created by Nathan Andrus on 3/11/19.
//  Copyright © 2019 Nathan Andrus. All rights reserved.
//

import UIKit

class EventTableViewCell: UITableViewCell {
    
    var eventCellLanding: Event? {
        didSet {
            updateViews()
        }
    }
    
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var eventLocationLabel: UILabel!
    @IBOutlet weak var eventDateTimeLabel: UILabel!
    @IBOutlet weak var numberOfAttendeesLabel: UILabel!
   
    func updateViews() {
        guard let event = eventCellLanding else { return }
        eventImageView.image = event.eventImage
        eventTitleLabel.text = event.eventTitle
        eventLocationLabel.text = event.location
        eventDateTimeLabel.text = "\(event.startTime)"
        numberOfAttendeesLabel.text = "Number of attendees: \(event.attendees.count)"
    }
}
