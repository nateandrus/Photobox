//
//  Page2CreateEventViewController.swift
//  Photobox
//
//  Created by Brayden Harris on 3/12/19.
//  Copyright © 2019 Nathan Andrus. All rights reserved.
//

import UIKit

class Page2CreateEventViewController: UIViewController {

    // MARK: -IBOutlets
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    
    // MARK: - Landing Pad
    var name: String?
    var location: String?
    var image: UIImage?
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = name
        startDatePicker.minimumDate = Date()
        endDatePicker.minimumDate = startDatePicker.date
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        DispatchQueue.main.async {
            self.navigationController?.popToRootViewController(animated: false)
        }
    }
    
    // MARK: - IBActions
    @IBAction func backButtonTapped(_ sender: Any) {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func startDateChanged(_ sender: Any) {
        //Update the end date to equal the start date
        endDatePicker.minimumDate = startDatePicker.date
    }
    
    @IBAction func endDateChanged(_ sender: Any) {
        //If the user chooses an end date before the start date, update the start date to equal the current end date
        if endDatePicker.date < startDatePicker.date {
            startDatePicker.date = endDatePicker.date
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as? Page3CreateEventViewController
        destination?.name = self.name
        destination?.location = self.location
        destination?.image = self.image
        destination?.startDate = startDatePicker.date
        destination?.endDate = endDatePicker.date
    }

}
