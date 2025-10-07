//
//  UITabbar+Extension.swift
//  Car-rent-ios-app
//
//  Created by Nikunj Vaghela on 29/11/22.
//

import Foundation
import UIKit

extension UITabBar {
    func addBadge(index:Int) {
        if let tabItems = self.items {
            let tabItem = tabItems[index]
            tabItem.badgeValue = ""
            tabItem.badgeColor = .clear
//            tabItem.setTitleTextAttributes(<#T##attributes: [NSAttributedString.Key : Any]?##[NSAttributedString.Key : Any]?#>, for: <#T##UIControl.State#>)
            tabItem.setBadgeTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.red], for: .normal)
        }
    }
    func removeBadge(index:Int) {
        if let tabItems = self.items {
            let tabItem = tabItems[index]
            tabItem.badgeValue = nil
        }
    }
    
 }
