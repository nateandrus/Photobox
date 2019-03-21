//
//  AttendeeEditViewController.swift
//  Photobox
//
//  Created by Nathan Andrus on 3/11/19.
//  Copyright © 2019 Nathan Andrus. All rights reserved.
//

import UIKit
import CloudKit

class AttendeeEditViewController: UIViewController {
    
    @IBOutlet weak var leaveEventLabel: UIButton!
    
    var eventLandingPad: Event? 
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func leaveEventButtonTapped(_ sender: UIButton) {
        guard let event = eventLandingPad, let user = UserController.shared.loggedInUser else { return }
        let reference = CKRecord.Reference(recordID: user.ckRecord, action: .none)
        
        if event.creatorReference == reference {
            alertControllerForEventCreator()
        } else {
            alertControllerForAttendee()
        }
    }
    
    func alertControllerForAttendee() {
        let alertController = UIAlertController(title: "Leave Event?", message: "Are you sure you want to leave the event?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        let leaveAction = UIAlertAction(title: "Leave", style: .destructive) { (_) in
            guard let reference = UserController.shared.loggedInUser?.creatorReference,
            let event = self.eventLandingPad else { return }
            EventController.shared.removeAttendee(creatorReference: reference, fromEvent: event, completion: { (success) in
                if success {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            })
        }
        alertController.addAction(cancelAction)
        alertController.addAction(leaveAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func alertControllerForEventCreator() {
        let alertController = UIAlertController(title: "Delete Event?", message: "Are you sure you want to delete the event?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        let leaveAction = UIAlertAction(title: "Delete", style: .destructive) { (_) in
            guard let event = self.eventLandingPad else { return }
            EventController.shared.delete(event: event, completion: { (success) in
                if success {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            })
        }
        alertController.addAction(cancelAction)
        alertController.addAction(leaveAction)
        present(alertController, animated: true, completion: nil)
    }
}
