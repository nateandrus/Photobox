//
//  Page3CreateEventViewController.swift
//  Photobox
//
//  Created by Brayden Harris on 3/12/19.
//  Copyright © 2019 Nathan Andrus. All rights reserved.
//

import UIKit
import Contacts
import CloudKit

class Page3CreateEventViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var resultsTableView: UITableView!
    
    // Shared Instance/Singleton
    static let shared = Page3CreateEventViewController()
    
    // MARK: - Landing Pad items
    var name: String?
    var location: String?
    var image: UIImage?
    var startDate: Date?
    var endDate: Date?
    
    // MARK: - Properties
    var invitedUsers: [CKRecord.Reference] = []
    var searchResults: ([CNContact], [User])? {
        didSet {
            DispatchQueue.main.async {
                self.resultsTableView.reloadData()
            }
        }
    }
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = name
        resultsTableView.delegate = self
        resultsTableView.dataSource = self
        searchBar.delegate = self
        
        descriptionTextView.layer.borderWidth = 1
        
        ContactController.shared.fetchContacts { (success) in
            if success {
                DispatchQueue.main.async {
                    self.resultsTableView.reloadData()
                }
            }
        }
    }
    
    // MARK: - IBActions
    @IBAction func backButtonTapped(_ sender: Any) {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func createButtonTapped(_ sender: Any) {
        guard let name = name,
            let location = location,
            let image = image,
            let startDate = startDate,
            let endDate = endDate,
            let eventDescription = descriptionTextView.text
            else { return }
        
        EventController.shared.createEvent(eventImage: image, eventTitle: name, location: location, startTime: startDate, endTime: endDate, description: eventDescription, invitedUsers: invitedUsers) { (success) in
            DispatchQueue.main.async {
                self.tabBarController?.selectedIndex = 0
            }
        }
    }
}
extension Page3CreateEventViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        UserController.shared.fetchUsersWith(searchTerm: searchText.lowercased()) { (contacts, users) in
            guard let contacts = contacts,
                let users = users else { return }
            
            self.searchResults = (contacts, users)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension Page3CreateEventViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let searchResults = searchResults else { return 1 }
        
        if searchResults.0.count > 0 && searchResults.1.count > 0 {
            return 2
        } else if searchResults.0.count > 0 || searchResults.1.count > 0{
            return 1
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let searchResults = searchResults else { return "Contacts" }
            
        if searchResults.0.count > 0 && searchResults.1.count > 0 {
            if section == 0 {
                return "Contacts"
            } else {
                return "Users"
            }
        } else if searchResults.0.count > 0 {
            return "Contacts"
        } else {
            return "Users"
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //If the user hasn't started a search, fill up the tableview with the user's contacts
        guard let searchResults = searchResults else { return ContactController.shared.contacts.count }
        
        //If the searchResults tuple contains values in both arrays
        if searchResults.0.count > 0 && searchResults.1.count > 0 {
            if section == 0 {
                return searchResults.0.count
            } else {
                return searchResults.1.count
            }
        //If the searchResults tuple contains results in the contacts array
        } else if searchResults.0.count > 0 {
            print(searchResults.0.count)
            return searchResults.0.count
        //If the searchResults tuple contains results in the users array
        } else if searchResults.1.count > 0 {
            print(searchResults.1.count)
            return searchResults.1.count
        //If both arrays are empty within the searchResults tuple
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let searchResults = searchResults else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath) as? ContactTableViewCell
            
            let contact = ContactController.shared.contacts[indexPath.row]
            
            cell?.contact = contact
            
            return cell ?? UITableViewCell()
            
            // if contact.username != nil {
            //     cell?.usernameLabel.text = "@\(contact.username)"
            // } else {
            //     cell?.usernameLabel.text = contact.phoneNumbers.first
            // }
        }
        
        if tableView.numberOfSections == 2 {
            if indexPath.section == 0 {

                let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath) as? ContactTableViewCell
                
                let contact = searchResults.0[indexPath.row]
                
                cell?.contact = contact
                
                return cell ?? UITableViewCell()
                    //if contact.username != nil {
                    //    cell?.usernameLabel.text = "@\(contact.username)"
                    //} else {
                    //    cell?.usernameLabel.text = contact.phoneNumbers.first
                    //}
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as? ContactTableViewCell
                
                let user = searchResults.1[indexPath.row]
                
                // TODO: Find a user's name
                // cell?.nameLabel = user.name
                
                cell?.user = user
                
                return cell ?? UITableViewCell()
            }
        } else {
            if searchResults.0.count > 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath) as? ContactTableViewCell
                
                let contact = searchResults.0[indexPath.row]
                
                cell?.contact = contact
                
                return cell ?? UITableViewCell()
                //if contact.username != nil {
                //    cell?.usernameLabel.text = "@\(contact.username)"
                //} else {
                //    cell?.usernameLabel.text = contact.phoneNumbers.first
                //}
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as? ContactTableViewCell
                
                let user = searchResults.1[indexPath.row]
                
                // TODO: Find a user's name
                // cell?.nameLabel = user.name
                
                cell?.user = user
                
                return cell ?? UITableViewCell()
            }
        }
    }
}
