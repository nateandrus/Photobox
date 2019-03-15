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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
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
        if tableView.numberOfSections == 2 {
            if section == 0 {
                if UserController.shared.eventsForFeed.0.count == 1 {
                    return "Current Event"
                } else {
                    return "Current Events"
                }
            } else if section == 1 {
                if UserController.shared.eventsForFeed.1.count == 1 {
                    return "Future Event"
                } else {
                    return "Future Events"
                }
            }
        } else if tableView.numberOfSections == 1 {
            if UserController.shared.eventsForFeed.0.count == 0 {
                if UserController.shared.eventsForFeed.1.count == 1 {
                    return "Future Event"
                } else {
                    return "Future Events"
                }
            } else {
                if UserController.shared.eventsForFeed.0.count == 1 {
                    return "Current Event"
                } else {
                    return "Current Events"
                }
            }
        }
        return ""
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return UserController.shared.eventsForFeed.0.count
        } else if section == 1 {
            return UserController.shared.eventsForFeed.1.count
        }
        return 0
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
//                if let destinationVC = segue.destination as? FeedDetailViewController {
//                    let eventToSend = EventController.shared.events[index.row]
//                    destinationVC.eventLandingPad = eventToSend
//                }
            }
        }
    }
}
