//
//  UIColor+Extension.swift

//
//   Created by Vishal on 30/09/21.
//  Copyright © 2020 Vishal. All rights reserved.
//

import UIKit

enum ColorPalette {
    case transparentBackground
    case transparentBackgroundWith70Alpha
    case black
    case white
    case greenBrand
    
    var color: UIColor {
        switch self {
        case .transparentBackground:
            UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        case .transparentBackgroundWith70Alpha:
            UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        case .black:
            UIColor.black
        case .white:
            UIColor.white
        case .greenBrand:
            UIColor(red: 0.22, green: 0.71, blue: 0.29, alpha: 1.00)
        }
    }
}

extension UIColor {

    static var orangeButtonAppColor = UIColor(named: "OrangeAppButtonColor")!
    static var blackTextAppColor = UIColor(named: "BlackTextAppColor")!

  
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
    
    static func hexStringToUIColor(hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
   

