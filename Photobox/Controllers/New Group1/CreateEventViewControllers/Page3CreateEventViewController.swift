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
import MessageUI

class Page3CreateEventViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var resultsTableView: UITableView!
    @IBOutlet weak var addedFriendsCollectionView: UICollectionView!
    @IBOutlet var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchBarTopRestraint: NSLayoutConstraint!
    
    // MARK: - Landing Pad items
    var name: String?
    var location: String?
    var image: UIImage?
    var startDate: Date?
    var endDate: Date?
    
    // MARK: - Properties
    var invitedUsers: [CKRecord.Reference] = []
    var textMessageRecipients: [String] = []
    
    var addedFriends: ([User], [CNContact]) = ([], []) {
        didSet {
            DispatchQueue.main.async {
                self.addedFriendsCollectionView.reloadData()
            }
        }
    }

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
        addedFriendsCollectionView.dataSource = self
        
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.cornerRadius = descriptionTextView.frame.width / 32
        
        ContactController.shared.fetchContacts { (success) in
            if success {
                DispatchQueue.main.async {
                    self.resultsTableView.reloadData()
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        DispatchQueue.main.async {
            self.resultsTableView.reloadData()
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
            let startDate = startDate else { return }
        
        if !textMessageRecipients.isEmpty {
            // Create accounts using their phone numbers
            let dispatchGroup = DispatchGroup()
            
            for phoneNumber in textMessageRecipients {
                dispatchGroup.enter()
                var formattedPhoneNumber = phoneNumber.components(separatedBy: NSCharacterSet.decimalDigits.inverted).joined()
                if formattedPhoneNumber.count > 10 {
                    formattedPhoneNumber.removeFirst()
                }
                
                UserController.shared.saveUserWith(username: nil, password: nil, phoneNumber: formattedPhoneNumber) { (success, user) in
                    if success {
                        guard let user = user else { return }
                        
                        let recordID = user.ckRecord
                        
                        let reference = CKRecord.Reference(recordID: recordID, action: .none)
                        
                        self.invitedUsers.append(reference)
                        self.addedFriends.0.append(user)
                        dispatchGroup.leave()
                    }
                }
            }
            dispatchGroup.notify(queue: .main) {
                self.createEvent()
                
                let composeVC = MFMessageComposeViewController()
                
                // Set delegate for MessageComposeViewController
                composeVC.messageComposeDelegate = self
                
                // Configure the fields of the interface
                composeVC.recipients = self.textMessageRecipients
                composeVC.body = "Hey! Join me at \(name) on \(startDate.stringWith(dateStyle: .medium, timeStyle: .short))! Download PhotoBOX to accept my invitation: (URL)."
                
                // Present the view controller modally
                if MFMessageComposeViewController.canSendText() {
                    self.navigationController?.present(composeVC, animated: true)
                }
            }
        } else {
            createEvent()
            DispatchQueue.main.async {
                let mainVC = self.navigationController?.viewControllers.first as? Page1CreateEventViewController
                mainVC?.fromCreate = true
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
        
    }
    
    func createEvent() {
        guard let name = name,
            let location = location,
            let image = image,
            let startDate = startDate,
            let endDate = endDate,
            let eventDescription = descriptionTextView.text else { return }
        
        EventController.shared.createEvent(eventImage: image, eventTitle: name, location: location, startTime: startDate, endTime: endDate, description: eventDescription, invitedUsers: invitedUsers) { (success, event)  in
            guard let event = event else { return }
            
            let reference = CKRecord.Reference(recordID: event.ckrecordID, action: .deleteSelf)
            
            for user in self.addedFriends.0 {
                // Update CloudKit
                UserController.shared.modify(user: user, withUsername: nil, password: nil, profileImage: nil, invitedEvents: [reference], completion: { (success) in
                    // If unsuccessful, print to console
                    if !success {
                        print("Unable to modify user")
                        return
                    }
                })
            }
        }
    }
}
extension Page3CreateEventViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        UserController.shared.fetchUsersWith(searchTerm: searchText.lowercased()) { (contacts, users) in
            guard let contacts = contacts,
                let users = users else { self.searchResults = nil; return }
            
           self.searchResults = (contacts, users)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension Page3CreateEventViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
            return searchResults.0.count
        //If the searchResults tuple contains results in the users array
        } else if searchResults.1.count > 0 {
            return searchResults.1.count
        //If both arrays are empty within the searchResults tuple
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let searchResults = searchResults else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath) as? ContactTableViewCell
            cell?.addButton.setTitle("+", for: .normal)
            
            let contact = ContactController.shared.contacts[indexPath.row]
            
            if addedFriends.1.contains(contact) {
                cell?.addButton.setTitle("✓", for: .normal)
            }
            
            cell?.contact = contact
            
            //Set delegate to self
            cell?.delegate = self
            
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
                cell?.addButton.setTitle("+", for: .normal)
                let contact = searchResults.0[indexPath.row]
                
                if addedFriends.1.contains(contact) {
                    cell?.addButton.setTitle("✓", for: .normal)
                    
                }
                
                cell?.contact = contact
                
                //Set delegate to self
                cell?.delegate = self
                
                return cell ?? UITableViewCell()
                    //if contact.username != nil {
                    //    cell?.usernameLabel.text = "@\(contact.username)"
                    //} else {
                    //    cell?.usernameLabel.text = contact.phoneNumbers.first
                    //}
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as? ContactTableViewCell
                cell?.addButton.setTitle("+", for: .normal)
                let user = searchResults.1[indexPath.row]
                
                // TODO: Find a user's name
                // cell?.nameLabel = user.name
                
                cell?.user = user
                
                if addedFriends.0.contains(user) {
                     cell?.addButton.setTitle("✓", for: .normal)
                }
                
                //Set delegate to self
                cell?.delegate = self
                
                return cell ?? UITableViewCell()
            }
        } else {
            if searchResults.0.count > 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath) as? ContactTableViewCell
                cell?.addButton.setTitle("+", for: .normal)
                let contact = searchResults.0[indexPath.row]
                
                cell?.contact = contact
                
                if addedFriends.1.contains(contact) {
                     cell?.addButton.setTitle("✓", for: .normal)
                }
                
                //Set delegate to self
                cell?.delegate = self
                
                return cell ?? UITableViewCell()
                //if contact.username != nil {
                //    cell?.usernameLabel.text = "@\(contact.username)"
                //} else {
                //    cell?.usernameLabel.text = contact.phoneNumbers.first
                //}
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as? ContactTableViewCell
                cell?.addButton.setTitle("+", for: .normal)
                let user = searchResults.1[indexPath.row]
                
                // TODO: Find a user's name
                // cell?.nameLabel = user.name
                
                if addedFriends.0.contains(user) {
                    cell?.addButton.setTitle("✓", for: .normal)
                }
                
                cell?.user = user
                
                //Set delegate to self
                cell?.delegate = self
                
                return cell ?? UITableViewCell()
            }
        }
    }
}
extension Page3CreateEventViewController: ContactTableViewCellDelegate {
    
    func addButtonTapped(_ cell: ContactTableViewCell, contact: CNContact?, user: User?, completion: @escaping (Bool) -> Void) {
        addPersonToEvent(cell, contact: contact, user: user) { (didAdd) in
            if didAdd {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func addPersonToEvent(_ cell: ContactTableViewCell, contact: CNContact?, user: User?, completion: @escaping (Bool) -> Void) {
        // If the cell is a contact
        if contact != nil {
            guard let contact = contact else { completion(false); return }
            
            // Check to see if the contact is already a user
            for phoneNumber in contact.phoneNumbers {
                var stringPhoneNumber = phoneNumber.value.stringValue.components(separatedBy: NSCharacterSet.decimalDigits.inverted).joined()
                if stringPhoneNumber.count > 10 {
                    stringPhoneNumber.removeFirst()
                }
                
                // If the phone number isn't connected to a user, continue looping through the phone numbers until it is verified that each number isn't connected to a user
                if !phoneNumberIsAUser(phoneNumber: stringPhoneNumber) {
                    continue
                } else {
                    completion(true)
                    return
                }
            }
            
            // After verifying that the contact is not a user
            // If the contact has more than one phone number, have the user select which phone number to send a text message invitation to
            if contact.phoneNumbers.count > 1 {
                let alertController = UIAlertController(title: "Send invitation to join your event", message: "Which phone number would you like to send the invitation to?", preferredStyle: .actionSheet)
                
                var actions: [UIAlertAction] = []
                
                for phoneNum in contact.phoneNumbers {
                    actions.append(UIAlertAction(title: "\(phoneNum.value.stringValue)", style: .default, handler: { (_) in
                        self.textMessageRecipients.append(phoneNum.value.stringValue)
                        self.addedFriends.1.append(contact)
                        completion(true)
                    }))
                }
                
                actions.append(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                
                for action in actions {
                    alertController.addAction(action)
                }
                
                self.present(alertController, animated: true)
            }
                // If the contact only has one phone number, add it to the recipients for the text message
            else if contact.phoneNumbers.count == 1 {
                guard let recipient = contact.phoneNumbers.first?.value.stringValue else { completion(false); return }
                self.textMessageRecipients.append(recipient)
                self.addedFriends.1.append(contact)
                completion(true)
            }
                // If there are no phone numbers associated with the contact, ask the user for a phone number
            else {
                let alertController = UIAlertController(title: "No phone number for \(contact.givenName)", message: nil, preferredStyle: .alert)
                
                alertController.addTextField { (textField) in
                    textField.placeholder = "Enter a phone number for \(contact.givenName)..."
                }
                
                let sendInviteAction = UIAlertAction(title: "Send Invite", style: .default) { (_) in
                    guard let phoneNumber = alertController.textFields?.first?.text?.components(separatedBy: NSCharacterSet.decimalDigits.inverted).joined() else { return }
                    
                    // If the phone number is not a user, add the phone to a list of recipients to send a text message to download the app and join the event
                    if !self.phoneNumberIsAUser(phoneNumber: phoneNumber) {
                        self.textMessageRecipients.append(phoneNumber)
                        self.addedFriends.1.append(contact)
                        completion(true)
                    }
                }
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
                    completion(false)
                }
                
                alertController.addAction(sendInviteAction)
                alertController.addAction(cancelAction)
                
                self.present(alertController, animated: true)
            }
        }
            // If the cell is a user
        else {
            guard let user = user,
                !addedFriends.0.contains(user) else { completion(false); return }
            
            let reference = CKRecord.Reference(recordID: user.ckRecord, action: .none)
            
            self.invitedUsers.append(reference)
            self.addedFriends.0.append(user)
            completion(true)
        }
    }
    
    func phoneNumberIsAUser(phoneNumber: String) -> Bool {
 
        let filteredUsers = UserController.shared.users.filter { (user) -> Bool in
            return user.phoneNumber == phoneNumber
        }
        
        // If the phone number is a user, add the user to invited users
        if filteredUsers.count > 0 {
            guard let recordID = filteredUsers.first?.ckRecord else { return false }
            
            let reference = CKRecord.Reference(recordID: recordID, action: .none)
            
            guard !addedFriends.0.contains(filteredUsers.first!) else { return true }
            self.invitedUsers.append(reference)
            self.addedFriends.0.append(filteredUsers.first!)
            return true
        } else {
            return false
        }
    }
}
extension Page3CreateEventViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let numFriends = addedFriends.0.count + addedFriends.1.count
        
        if numFriends > 1 {
            searchBarTopRestraint.constant = 0
            contentViewBottomConstraint.constant += 60
        } else if numFriends > 0 {
            searchBarTopRestraint.constant = -30
            contentViewBottomConstraint.constant += 30
        } else {
            searchBarTopRestraint.constant = -60
            contentViewBottomConstraint.constant = 0
        }
        
        return numFriends
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "friendCell", for: indexPath) as? AddedFriendCollectionViewCell
        
        cell?.contact = nil
        cell?.user = nil
        
        if indexPath.row < addedFriends.0.count {
            cell?.user = addedFriends.0[indexPath.row]
            // Set delegate = to self
            cell?.delegate = self
            
            return cell ?? UICollectionViewCell()
        } else {
            cell?.contact = addedFriends.1[indexPath.row - addedFriends.0.count]
            // Set delegate = to self
            cell?.delegate = self
            
            return cell ?? UICollectionViewCell()
        }
    }
}
extension Page3CreateEventViewController: AddedFriendCollectionViewCellDelegate {
    func removeButtonTapped(_ cell: AddedFriendCollectionViewCell, contact: CNContact?, user: User?) {
        if contact != nil {
            guard let friendsIndex = addedFriends.1.index(of: contact!),
            let phoneNumbers = contact?.phoneNumbers else { return }
            
            let phoneNumbersStrings = phoneNumbers.compactMap { (phoneNumber) -> String? in
                return phoneNumber.value.stringValue
            }
            
            for phoneNum in phoneNumbersStrings {
                guard let index = textMessageRecipients.index(of: phoneNum) else { continue }
               
                textMessageRecipients.remove(at: index)
                break
            }
            
            addedFriends.1.remove(at: friendsIndex)
        } else {
            guard let friendsIndex = addedFriends.0.index(of: user!),
                let recordID = user?.ckRecord else { return }
            addedFriends.0.remove(at: friendsIndex)
            
            let reference = CKRecord.Reference(recordID: recordID, action: .none)
            guard let invitedUserIndex = invitedUsers.index(of: reference) else { return }
            invitedUsers.remove(at: invitedUserIndex)
        }
    }
}
extension Page3CreateEventViewController: MFMessageComposeViewControllerDelegate {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true) {
            DispatchQueue.main.async {
                let mainVC = self.navigationController?.viewControllers.first as? Page1CreateEventViewController
                mainVC?.fromCreate = true
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
}
