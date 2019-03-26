//
//  NoPendingInvitesViewController.swift
//  Photobox
//
//  Created by Brayden Harris on 3/26/19.
//  Copyright © 2019 Nathan Andrus. All rights reserved.
//

import UIKit

class NoPendingInvitesViewController: UIViewController {

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.navigationController?.popToRootViewController(animated: false)
    }
}
