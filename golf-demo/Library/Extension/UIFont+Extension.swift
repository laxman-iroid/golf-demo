//
//  UIFont+Extension.swift

//
//   Created by Vishal on 30/09/21.
//  Copyright © 2020 Vishal. All rights reserved.
//

import Foundation
import UIKit

enum themeFonts : String {
    
    case black = "AirbnbCereal-Black"
    case bold = "AirbnbCerealApp-Bold"
    case book = "AirbnbCerealApp-Book"
    case regular = "AirbnbCerealApp-Regular"
//    case extraBold = "AirbnbCerealApp-ExtraBold"
    case light = "AirbnbCerealApp-Light"
    case medium = "AirbnbCerealApp-Medium"
}

func themeFont(size : Float,fontname : themeFonts) -> UIFont {
    
    if UIScreen.main.bounds.width <= 320 {
        return UIFont(name: fontname.rawValue, size: CGFloat(size) - 2.0)!
    }
    else {
        return UIFont(name: fontname.rawValue, size: CGFloat(size))!
    }
}

extension UIFont {
    enum ThemeFont: String {
        case displayMedium = "SF-Pro-Display-Medium"
    }
    
    enum FontSize: CGFloat {
        case s11 = 11.0
        case s12 = 12.0
        case s13 = 13.0
        case s14 = 14.0
        case s16 = 16.0
        case s22 = 22.0
    }
    
    static func themeFont(_ font: ThemeFont, size: FontSize) -> UIFont {
        UIFont(name: font.rawValue, size: size.rawValue) ?? UIFont.systemFont(ofSize: size.rawValue)
    }
}

extension UILabel {
    convenience init(
        text: String,
        font: UIFont.ThemeFont,
        fontSize: UIFont.FontSize,
        textColor: ColorPalette = .black,
        alignment: NSTextAlignment = .left
    ) {
        self.init()
        self.text = text
        self.font = UIFont.themeFont(font, size: fontSize)
        self.textColor = textColor.color
        self.textAlignment = alignment
        self.numberOfLines = 0
        self.lineBreakMode = .byWordWrapping
    }
}
