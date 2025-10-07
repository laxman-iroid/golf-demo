//
//  UIViewController+Extension.swift
//  HandyGolf
//
//  Created by iMac on 01/07/24.
//

import Foundation
import UIKit


extension UIViewController {
        
    func showAlertDialogue(title: String?, message: String?, preferredStyle: UIAlertController.Style = .alert, actions: [UIAlertAction]? = nil, completion: (() -> Void)? = nil, onYesClick: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)

        if let actions = actions {
            for action in actions {
                alertController.addAction(action)
            }
        } else {
            
            let noAction = UIAlertAction(title: "No", style: UIAlertAction.Style.default, handler: { _ in
                self.dismiss(animated: true)
            })
            
            let yesAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.destructive, handler: { _ in
                onYesClick?()
            })
            
            alertController.addAction(noAction)
            alertController.addAction(yesAction)
        }

        present(alertController, animated: true, completion: completion)
    }
}
