//
//  UITextField+Extension.swift
//  GoLocal_Seller
//
//  Created by iMac on 17/02/25.
//

import Foundation
import UIKit

extension UITextView {
    // MARK: - Text View Limit
    func removeTextUntilSatisfying(maxNumberOfLines: Int) {
        while 50 > (maxNumberOfLines) {
            text = String(text.dropLast())
            layoutIfNeeded()
        }
    }
}
