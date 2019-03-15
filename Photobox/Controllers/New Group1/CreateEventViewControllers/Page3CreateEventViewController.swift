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
    
    var searchResults: [User]? {
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
        ContactController.shared.fetchContacts()
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
    
//    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
//        <#code#>
//    }
//    
//    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
//        <#code#>
//    }
//    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        UserController.shared.fetchUsersWith(searchTerm: searchText) { (users, contacts) in
            guard let users = users else { return }
            
            self.searchResults = users
        }
    }
}
extension Page3CreateEventViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        if searchResults != nil && ContactController.shared.contacts.count > 0 {
            return 2
        } else if searchResults != nil {
            return 1
        } else if ContactController.shared.contacts.count > 0 {
            return 1
        } else {
            return 0
        }
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if tableView.numberOfSections == 2 {
            return ["", "Contacts"]
        } else {
            return ["Contacts"]
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchResults != nil && ContactController.shared.contacts.count > 0 {
            if section == 0 {
                return searchResults?.count ?? 0
            } else {
                return ContactController.shared.contacts.count
            }
        } else if searchResults != nil {
            return searchResults?.count ?? 0
        } else if ContactController.shared.contacts.count > 0 {
            return ContactController.shared.contacts.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isSearching == false {
            if ContactController.shared.contacts.count > 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath) as? ContactTableViewCell
                let contact = ContactController.shared.contacts[indexPath.row]
                cell?.contact = contact
                return cell ?? UITableViewCell()
            }
        } else if isSearching == true {

        }
        return UITableViewCell()
    }
}
