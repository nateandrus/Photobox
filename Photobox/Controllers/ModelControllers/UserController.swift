//
//  UserController.swift
//  Photobox
//
//  Created by Nathan Andrus on 3/11/19.
//  Copyright © 2019 Nathan Andrus. All rights reserved.
//

import Foundation
import CloudKit

class UserController {
    
    static let shared = UserController()
    
    var loggedInUser: User?
    
    let publicDB = CKContainer.default().publicCloudDatabase
    
}

