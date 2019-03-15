//
//  Page3CreateEventViewController.swift
//  Photobox
//
//  Created by Brayden Harris on 3/12/19.
//  Copyright © 2019 Nathan Andrus. All rights reserved.
//

import UIKit
import Contacts

class Page3CreateEventViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var resultsTableView: UITableView!
    
    // MARK: - Landing Pad items
    var name: String?
    var location: String?
    var image: UIImage?
    var startDate: Date?
    var endDate: Date?
    
    var isSearching: Bool = false
    
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
        resultsTableView.delegate = self
        resultsTableView.dataSource = self
        searchBar.delegate = self
        
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
        
        EventController.shared.createEvent(eventImage: image, eventTitle: name, location: location, startTime: startDate, endTime: endDate, description: eventDescription) { (success) in
            self.tabBarController?.selectedIndex = 0 
        }
    }
}
extension Page3CreateEventViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        isSearching = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        isSearching = false
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        UserController.shared.fetchUsersWith(searchTerm: searchText) { (contacts, users) in
            guard let contacts = contacts,
                let users = users else { return }
            
            self.searchResults = (contacts, users)
        }
    }
}

extension Page3CreateEventViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let searchResults = searchResults else { return 1 }
        if searchResults.0.count > 0 || searchResults.1.count > 0 {
            return 2
        } else {
            return 1
        }
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if tableView.numberOfSections == 2 {
            return ["Contacts", ""]
        } else {
            return ["Contacts"]
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
        } else if searchResults.0.count > 1 {
            if section == 0 {
                return searchResults.0.count
            } else {
                return 0
            }
        //If the searchResults tuple contains results in the users array
        } else if searchResults.1.count > 0 {
            if section == 0 {
                return 0
            } else {
                return searchResults.1.count
            }
        }
        //If both arrays are empty within the searchResults tuple
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if searchResults == nil {
            let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath) as? ContactTableViewCell
            
            let contact = ContactController.shared.contacts[indexPath.row]
        }
        
        if isSearching == false {
//            if ContactController.shared.contacts.count > 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "usernameCell", for: indexPath) as? ContactTableViewCell
                let contact = ContactController.shared.contacts[indexPath.row]
                cell?.contact = contact
                return cell ?? UITableViewCell()
//            }
//        } else if isSearching == true {
//
        }
        return UITableViewCell()
    }
}
