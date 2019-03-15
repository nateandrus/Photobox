//
//  PhoneNumberViewController.swift
//  Photobox
//
//  Created by Brayden Harris on 3/14/19.
//  Copyright © 2019 Nathan Andrus. All rights reserved.
//

import UIKit
import Contacts

class PhoneNumberViewController: UIViewController {

    @IBOutlet weak var phoneNumberTextField: UITextField!
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func OKButtonTapped(_ sender: Any) {
        guard let phoneNumber = phoneNumberTextField.text, !phoneNumber.isEmpty else { return }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
