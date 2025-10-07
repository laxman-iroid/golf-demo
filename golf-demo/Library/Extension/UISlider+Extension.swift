//
//  UISlider+Extension.swift
//  Car-rent-ios-app
//
//  Created by Nikunj Vaghela on 03/10/22.
//

import Foundation
import UIKit

extension UISlider {
    
    var trackBounds: CGRect {
        return trackRect(forBounds: bounds)
    }
    
    var trackFrame: CGRect {
        guard let superView = superview else { return CGRect.zero }
        return self.convert(trackBounds, to: superView)
    }
    
    var thumbBounds: CGRect {
        return thumbRect(forBounds: frame, trackRect: trackBounds, value: value)
    }
    
    var thumbFrame: CGRect {
        return thumbRect(forBounds: bounds, trackRect: trackFrame, value: value)
    }
    
    var thumbCenterX: CGFloat {
        let trackRect = self.trackRect(forBounds: bounds)
        let thumbRect = self.thumbRect(forBounds: bounds, trackRect: trackRect, value: value)
        return thumbRect.midX
    }
}
