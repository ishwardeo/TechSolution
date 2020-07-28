//
//  AlertViewController.swift
//  UsersList
//
//  Created by Mac on 28/07/20.
//  Copyright © 2020 TechSolution. All rights reserved.
//

import Foundation

import Foundation
import UIKit

struct AlertController {
    static func showAlertWith(fromVC vc: UIViewController, title: String, message: String, style: UIAlertController.Style = .alert) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        let action = UIAlertAction(title: "Cancel", style: .default) { (action) in
            vc.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(action)
        vc.present(alertController, animated: true, completion: nil)
    }
}
