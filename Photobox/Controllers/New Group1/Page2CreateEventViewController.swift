//
//  Page2CreateEventViewController.swift
//  Photobox
//
//  Created by Brayden Harris on 3/12/19.
//  Copyright © 2019 Nathan Andrus. All rights reserved.
//

import UIKit

class Page2CreateEventViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
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
