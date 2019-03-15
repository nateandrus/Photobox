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
}
