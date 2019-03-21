//
//  AttendeeEditViewController.swift
//  Photobox
//
//  Created by Nathan Andrus on 3/11/19.
//  Copyright © 2019 Nathan Andrus. All rights reserved.
//

import UIKit

class AttendeeEditViewController: UIViewController {
    
    @IBOutlet weak var leaveEventLabel: UIButton!
    
    var eventLandingPad: Event? 
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func leaveEventButtonTapped(_ sender: UIButton) {
        guard let event = eventLandingPad else { return }
        EventController.shared.delete(event: event) { (success) in
            if success {
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
}
