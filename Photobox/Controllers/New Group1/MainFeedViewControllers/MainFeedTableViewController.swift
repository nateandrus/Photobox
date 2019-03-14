//
//  MainFeedTableViewController.swift
//  Photobox
//
//  Created by Nathan Andrus on 3/11/19.
//  Copyright © 2019 Nathan Andrus. All rights reserved.
//

import UIKit

class MainFeedTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    //MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        if UserController.shared.eventsForFeed.0.count > 0 && UserController.shared.eventsForFeed.1.count > 0 {
            return 2
        } else if UserController.shared.eventsForFeed.0.count > 0 && UserController.shared.eventsForFeed.1.count == 0 {
            return 1
        } else if UserController.shared.eventsForFeed.0.count == 0 && UserController.shared.eventsForFeed.1.count > 0 {
            return 1
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as? EventTableViewCell
        let event = EventController.shared.events[indexPath.row]
        cell?.eventCellLanding = event
        return cell ?? UITableViewCell()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEventDetailVC" {
            if let index = tableView.indexPathForSelectedRow {
                if let destinationVC = segue.destination as? FeedDetailViewController {
                    let eventToSend = EventController.shared.events[index.row]
                    destinationVC.eventLandingPad = eventToSend
                }
            }
        }
    }
}
