//
//  UILabel+Extension.swift

//
//   Created by Vishal on 30/09/21.
//  Copyright © 2020 Vishal. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {
    
    func getLabelHeight() -> (Int,Int){
        var lineCount = 0
        let textSize = CGSize(width: self.frame.size.width, height: CGFloat(MAXFLOAT))
        let rHeight = lroundf(Float(self.sizeThatFits(textSize).height))
        let charSize = lroundf(Float(self.font.lineHeight))
        lineCount = rHeight / charSize
        return (lineCount,rHeight)
    }
    
    func actualNumberOfLines() -> Int {
        // You have to call layoutIfNeeded() if you are using autoLayout
        self.layoutIfNeeded()
        
        let myText = self.text as NSString?
        
        let rect = CGSize(width: self.bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let labelSize = myText?.boundingRect(with: rect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: self.font as Any], context: nil)
        
        return Int(ceil(CGFloat(labelSize?.height ?? 0.0) / self.font.lineHeight))
    }
    
    func addImageToLabel(imageName: String, strText : String, aboveString : String) {
        
        let imageAttachment =  NSTextAttachment()
        imageAttachment.image = UIImage(named:imageName)
        //Set bound to reposition
        let imageOffsetY:CGFloat = -5.0;
        
        imageAttachment.bounds = CGRect(x: 0, y: imageOffsetY, width: imageAttachment.image!.size.width, height: imageAttachment.image!.size.height)
        
        let str = NSMutableAttributedString(string: aboveString)
        
        //Create string with attachment
        let attachmentString = NSAttributedString(attachment: imageAttachment)
        //Initialize mutable string
        
        str.append(attachmentString)
        
        let completeText = NSMutableAttributedString(string: "")
        //Add image to mutable string
        completeText.append(str)
        //Add your text to mutable string
        let  textAfterIcon = NSMutableAttributedString(string: strText)
        completeText.append(textAfterIcon)
        
        self.attributedText = completeText
       
    }
    
    func addDifferenceColorinLabel(str1:String,color1:UIColor,str2:String,color2:UIColor) {
        let attrs1 = [NSAttributedString.Key.foregroundColor : color1]
        let attrs2 = [NSAttributedString.Key.foregroundColor : color2]
        let attributedString1 = NSMutableAttributedString(string:str1, attributes:attrs1)
        let attributedString2 = NSMutableAttributedString(string:str2, attributes:attrs2)
        attributedString1.append(attributedString2)
        self.attributedText = attributedString1
    }
    
    func underLineToLabelText() {
        if let textString = self.text {
            let attributedString = NSMutableAttributedString(string: textString)
            attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: attributedString.length - 1))
            attributedText = attributedString
        }
    }
    
    func applyGradientToTextWith(startColor: UIColor, endColor: UIColor) -> Bool {
        var startColorRed:CGFloat = 0
        var startColorGreen:CGFloat = 0
        var startColorBlue:CGFloat = 0
        var startAlpha:CGFloat = 0
        if !startColor.getRed(&startColorRed, green: &startColorGreen, blue: &startColorBlue, alpha: &startAlpha) {
            return false
        }
        var endColorRed:CGFloat = 0
        var endColorGreen:CGFloat = 0
        var endColorBlue:CGFloat = 0
        var endAlpha:CGFloat = 0

        if !endColor.getRed(&endColorRed, green: &endColorGreen, blue: &endColorBlue, alpha: &endAlpha) {
            return false
        }

        let gradientText = self.text ?? ""

//        let name:String = NSAttributedString.Key.font.rawValue
        let textSize: CGSize = gradientText.size(withAttributes: [NSAttributedString.Key.font : self.font as Any])
//        let textSize: CGSize = gradientText.size(attributes: [name:self.font])
        let width:CGFloat = textSize.width
        let height:CGFloat = textSize.height

        UIGraphicsBeginImageContext(CGSize(width: width, height: height))

        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return false
        }

        UIGraphicsPushContext(context)

        let glossGradient:CGGradient?
        let rgbColorspace:CGColorSpace?
        let num_locations:size_t = 2
        let locations:[CGFloat] = [ 0.0, 1.0 ]
        let components:[CGFloat] = [startColorRed, startColorGreen, startColorBlue, startAlpha, endColorRed, endColorGreen, endColorBlue, endAlpha]
        rgbColorspace = CGColorSpaceCreateDeviceRGB()
        glossGradient = CGGradient(colorSpace: rgbColorspace!, colorComponents: components, locations: locations, count: num_locations)
        let topCenter = CGPoint.zero
        let bottomCenter = CGPoint(x: 0, y: textSize.height)
        context.drawLinearGradient(glossGradient!, start: topCenter, end: bottomCenter, options: CGGradientDrawingOptions.drawsBeforeStartLocation)

        UIGraphicsPopContext()

        guard let gradientImage = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return false
        }

        UIGraphicsEndImageContext()

        self.textColor = UIColor(patternImage: gradientImage)

        return true
    }
    
    
}
extension UILabel {
    func addCharactersSpacing(spacing:CGFloat, text:String) {
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(NSAttributedString.Key.kern, value: spacing, range: NSMakeRange(0, text.count-1))
        self.attributedText = attributedString
    }
}
@IBDesignable class CustomLabel: UILabel {
    // Define available font styles for Poppins
    enum FontStyle: Int, CaseIterable {
        case regular
        case medium
        case semiBold
        case bold
        case black
        case merriRegular
        case merriBold
        
        var fontName: String {
            switch self {
            case .regular:
                return "OpenSans-Regular"
            case .medium:
                return "OpenSans-Medium"
            case .semiBold:
                return "OpenSans-SemiBold"
            case .bold:
                return "OpenSans-Bold"
            case .black:
                return "OpenSans-ExtraBold"
            case .merriRegular:
                return "Merriweather-Regular"
            case .merriBold:
                return "Merriweather-Bold"
            }
        }
        
        static func fontName(for index: Int) -> String {
            return FontStyle(rawValue: index)?.fontName ?? "OpenSans-Regular"
        }
    }
    
    // This property will appear in Interface Builder as a dropdown
    @IBInspectable var fontStyleIndex: Int = 0 {
        didSet {
            let fontName = FontStyle.fontName(for: fontStyleIndex)
            if let font = UIFont(name: fontName, size: fontSize) {
                self.font = font
            } else {
                print("Error: Font '\(fontName)' not found")
            }
        }
    }
    
    // Define your font size
    @IBInspectable var fontSize: CGFloat = 14.0 {
        didSet {
            self.font = self.font.withSize(fontSize)
        }
    }
}
