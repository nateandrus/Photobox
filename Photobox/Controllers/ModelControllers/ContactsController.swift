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
    
    func fetchContacts() {
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { (granted, error) in
            if let error = error {
                print("There was an error requesting contacts: \(error.localizedDescription)")
                return
            }
            if granted {
                let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                do {
                    try store.enumerateContacts(with: request, usingBlock: { (contact, stopPointer) in
                        self.contacts.append(contact)
                    })
                }catch{
                    print("double negative ghost rider")
                }
            } else {
                print("negative ghostrider")
            }
        }
    }
}
