//
//  EventController.swift
//  Photobox
//
//  Created by Nathan Andrus on 3/11/19.
//  Copyright © 2019 Nathan Andrus. All rights reserved.
//

import UIKit
import CloudKit

class EventController {
    
    static let shared = EventController()
    
    var events: [Event] = []
    
    //CRUD Functions
    //create
    func createEvent(eventImage: UIImage, eventTitle: String, location: String, startTime: Date, endTime: Date, description: String) {
        let newEvent = Event(eventImage: eventImage, eventTitle: eventTitle, location: location, startTime: startTime, endTime: endTime, description: description, creatorReference: <#T##CKRecord.Reference#>)
    }
    
    //read
    func fetchEvents() {
        
    }
    
    //update
    
    //delete
    
    
}
