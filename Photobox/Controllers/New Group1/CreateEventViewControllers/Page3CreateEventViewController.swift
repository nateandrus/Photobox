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
    
    // MARK: - Properties
    var name: String?
    var location: String?
    var image: UIImage?
    var startDate: Date?
    var endDate: Date?
    
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
    }
    
    // MARK: - IBActions
    @IBAction func backButtonTapped(_ sender: Any) {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func createButtonTapped(_ sender: Any) {
        
    }
}
extension Page3CreateEventViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        UserController.shared.fetchUsersWith(searchTerm: searchText) { (users, contacts) in
            guard let users = users else { return }
            
            self.searchResults = users
        }
    }
}
extension Page3CreateEventViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if searchResults != nil && contacts != nil {
            return 2
        } else if searchResults != nil {
            return 1
        } else if contacts != nil {
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
        if searchResults != nil && contacts != nil {
            if section == 0 {
                return searchResults?.count ?? 0
            } else {
                return contacts?.count ?? 0
            }
        } else if searchResults != nil {
            return searchResults?.count ?? 0
        } else if contacts != nil {
            return contacts?.count ?? 0
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let userCell
    }
    
    
}
