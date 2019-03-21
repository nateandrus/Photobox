//
//  FeedDetailViewController.swift
//  Photobox
//
//  Created by Nathan Andrus on 3/11/19.
//  Copyright © 2019 Nathan Andrus. All rights reserved.
//

import UIKit

class FeedDetailViewController: UIViewController {

    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var eventLocationLabel: UILabel!
    @IBOutlet weak var dateAndTimeLabel: UILabel!
    @IBOutlet weak var endDateandTimeLabel: UILabel!
    @IBOutlet weak var numberOfAttendeesLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var eventLandingPad: Event? {
        didSet {
            loadViewIfNeeded()
            updateViews()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Navigation
    func updateViews() {
        guard let event = eventLandingPad else { return }
        eventImageView.image = event.eventImage
        eventTitleLabel.text = event.eventTitle
        eventLocationLabel.text = event.location
        dateAndTimeLabel.text = "Start: \(event.startTime.stringWith(dateStyle: .medium, timeStyle: .short))"
        endDateandTimeLabel.text = "End: \(event.endTime.stringWith(dateStyle: .medium, timeStyle: .short))"
        numberOfAttendeesLabel.text = "Number of attendees: \(event.attendees.count)"
        descriptionLabel.text = event.description
        self.title = event.eventTitle
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toLeaveEvent" {
            guard let event = eventLandingPad else { return }
            let destination = segue.destination as? AttendeeEditViewController
            destination?.eventLandingPad = event
        }
    }
}
