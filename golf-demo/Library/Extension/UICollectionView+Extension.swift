//
//  UICollectionView+Extension.swift
//  GoLocal_User
//
//  Created by iMac on 19/08/25.
//

import Foundation
import UIKit

extension UIScrollView {
    
    func scrollToBottomCollctionView(isAnimated: Bool = true) {
        DispatchQueue.main.async {
            let bottomOffset = CGPoint(x: 0, y: self.contentSize.height - self.bounds.height + self.contentInset.bottom)
            if bottomOffset.y > 0 {
                self.setContentOffset(bottomOffset, animated: isAnimated)
            }
        }
    }
    
    func scrollToTopCollctionView(isAnimated: Bool = true) {
        DispatchQueue.main.async {
            let topOffset = CGPoint(x: 0, y: -self.contentInset.top)
            self.setContentOffset(topOffset, animated: isAnimated)
        }
    }
}
