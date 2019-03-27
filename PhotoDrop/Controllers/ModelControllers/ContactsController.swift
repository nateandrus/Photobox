//
//  ContactsController.swift
//  Photobox
//
//  Created by Nathan Andrus on 3/14/19.
//  Copyright © 2019 Nathan Andrus. All rights reserved.
//

import Foundation
import Contacts

class ContactController {
    
    static let shared = ContactController()
    
    var contacts: [CNContact] = []
    
    func fetchContacts(completion: @escaping (Bool) -> Void) {
        contacts.removeAll()
        
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { (granted, error) in
            if let error = error {
                print("There was an error requesting contacts: \(error.localizedDescription)")
                completion(false)
                return
            }
            if granted {
                let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                do {
                    try store.enumerateContacts(with: request, usingBlock: { (contact, stopPointer) in
                        self.contacts.append(contact)
                        self.contacts.sort(by: { $0.givenName < $1.givenName })
                        
                        completion(true)
                    })
                }catch{
                    print("double negative ghost rider")
                    completion(false)
                }
            } else {
                print("negative ghostrider")
                completion(false)
            }
        }
    }
    
    func fetchUserUsing(contact: CNContact, completion: @escaping ((String)?) -> Void) {
        
        let phoneNumber = contact.phoneNumbers.first?.value.stringValue
        let newNumber = phoneNumber?.replacingOccurrences(of: "-", with: "")
        
        let predicate = NSPredicate(format: "%K = %@", [User.phoneNumberKey, newNumber])
        
        CloudKitManager.shared.fetchRecordsWithType(User.typeKey, predicate: predicate, recordFetchedBlock: { (_) in
        }) { (records, error) in
            if let error = error {
                print("Couldn't fetch record with the phonenumber: \(error.localizedDescription)")
                completion(nil)
                return
            }
            guard let record = records else { completion(nil); return }
            if record.count > 0 {
                let ourRecord = record.first!
                let ourUser = User(record: ourRecord)
                completion(ourUser?.username)
            } else {
                completion(nil)
                return
            }
        }
    }
}
