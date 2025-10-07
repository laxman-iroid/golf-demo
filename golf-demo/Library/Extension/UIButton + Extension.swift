//
//  UIButton + Extension.swift

//
//   Created by Vishal on 30/09/21.
//  Copyright © 2020 Vishal. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    
    func setupThemeButtonUI(backColor:UIColor=UIColor.red,font:UIFont=themeFont(size: 20, fontname: .medium),fontColor:UIColor = .white) {
        self.setTitleColor(fontColor, for: .normal)
        self.backgroundColor = backColor
        self.titleLabel?.font = font
    }
    
//    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
//        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
//        let mask = CAShapeLayer()
//        mask.path = path.cgPath
//        layer.mask = mask
//    }
    
    func setUpThemeBackButtonUI() {
        self.setTitleColor(UIColor.black, for: .normal)
        self.titleLabel?.font = themeFont(size: 16, fontname: .medium)
    }
    
    func setImageTintColor(_ color: UIColor) {
        let tintedImage = self.imageView?.image?.withRenderingMode(.alwaysTemplate)
        self.setImage(tintedImage, for: .normal)
        self.tintColor = color
    }

    func underline() {
        guard let text = self.titleLabel?.text else { return }
        let attributedString = NSMutableAttributedString(string: text)
        //NSAttributedStringKey.foregroundColor : UIColor.blue
        attributedString.addAttribute(NSAttributedString.Key.underlineColor, value: self.titleColor(for: .normal)!, range: NSRange(location: 0, length: text.count))
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: self.titleColor(for: .normal)!, range: NSRange(location: 0, length: text.count))
        attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: text.count))
        self.setAttributedTitle(attributedString, for: .normal)
    }
}
