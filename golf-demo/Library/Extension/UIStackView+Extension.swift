//
//  UIStackView+Extension.swift
//  HandyGolf
//
//  Created by iMac on 27/11/24.
//

import Foundation
import UIKit

extension UIStackView {
    func rearrangeSubviews(_ views: [UIView], order: [Int]) {
        for (view, index) in zip(views, order) {
            removeArrangedSubview(view)
            insertArrangedSubview(view, at: index)
        }
    }
}
