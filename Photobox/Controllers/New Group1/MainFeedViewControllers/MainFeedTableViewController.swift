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
        
        EventController.shared.fetchEvents { (success) in
            if success {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        EventController.shared.sortEvents { (success) in
            if success {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }

    //MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        if EventController.shared.currentEvents.count > 0 && EventController.shared.futureEvents.count > 0 {
            return 2
        } else if EventController.shared.currentEvents.count > 0 && EventController.shared.futureEvents.count == 0 {
            return 1
        } else if EventController.shared.currentEvents.count == 0 && EventController.shared.futureEvents.count > 0 {
            return 1
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView.numberOfSections == 2 {
            if section == 0 {
                if EventController.shared.currentEvents.count == 1 {
                    return "Current Event"
                } else {
                    return "Current Events"
                }
            } else if section == 1 {
                if EventController.shared.futureEvents.count == 1 {
                    return "Future Event"
                } else {
                    return "Future Events"
                }
            }
        } else if tableView.numberOfSections == 1 {
            if EventController.shared.currentEvents.count == 0 {
                if EventController.shared.futureEvents.count == 1 {
                    return "Future Event"
                } else {
                    return "Future Events"
                }
            } else {
                if EventController.shared.currentEvents.count == 1 {
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
            if EventController.shared.currentEvents.count > 0 {
                return EventController.shared.currentEvents.count
            } else {
                return EventController.shared.futureEvents.count
            }
        } else if section == 1 {
            return EventController.shared.futureEvents.count
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as? EventTableViewCell
        if EventController.shared.currentEvents.count > 0 && EventController.shared.futureEvents.count > 0 {
            if indexPath.section == 0 {
                let event = EventController.shared.currentEvents[indexPath.row]
                cell?.eventCellLanding = event
                return cell ?? UITableViewCell()
            }
            if indexPath.section == 1 {
                let event = EventController.shared.futureEvents[indexPath.row]
                cell?.eventCellLanding = event
                return cell ?? UITableViewCell()
            }
        } else if EventController.shared.currentEvents.count == 0 {
            let event = EventController.shared.futureEvents[indexPath.row]
            cell?.eventCellLanding = event
            return cell ?? UITableViewCell()
        } else {
            let event = EventController.shared.currentEvents[indexPath.row]
            cell?.eventCellLanding = event
            return cell ?? UITableViewCell()
        }
        return UITableViewCell()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEventDetailVC" {
            if let index = tableView.indexPathForSelectedRow {
                if index.section == 0 {
                    if let destinationVC = segue.destination as? FeedDetailViewController {
                        let eventToSend = EventController.shared.currentEvents[index.row]
                        destinationVC.eventLandingPad = eventToSend
                    }
                } else if index.section == 1 {
                    if let destinationVC = segue.destination as? FeedDetailViewController {
                        let eventToSend = EventController.shared.futureEvents[index.row]
                        destinationVC.eventLandingPad = eventToSend
                    }
                }
            }
        }
    }
}
