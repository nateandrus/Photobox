//
//  UserProfileViewController.swift
//  Photobox
//
//  Created by Nathan Andrus on 3/12/19.
//  Copyright © 2019 Nathan Andrus. All rights reserved.
//

import UIKit

class UserProfileViewController: UIViewController {

    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var pastEventsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pastEventsTableView.delegate = self
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEventPhotoVC" {
            if let eventIndex = pastEventsTableView.indexPathForSelectedRow {
                if let destinationVC = segue.destination as? UserProfileDetailViewController {
                    let eventToSend = EventController.shared.events[eventIndex.row]
                    destinationVC.pastEventLanding = eventToSend
                }
            }
        }
    }
}

extension UserProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pastEventCell", for: indexPath) as? EventTableViewCell
        let event = EventController.shared.events[indexPath.row]
        cell?.eventCellLanding = event
        return cell ?? UITableViewCell()
    }
}
