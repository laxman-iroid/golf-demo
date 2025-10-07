//
//  String+Extension.swift

//
//   Created by Vishal on 30/09/21.
//  Copyright © 2020 Vishal. All rights reserved.
//

import Foundation
import UIKit

extension String {
    
    func isNumber() -> Bool {
           return self.range(of: "^[0-9]$", options: .regularExpression) != nil
       }
    
    var isNumeric: Bool {
        guard self.count > 0 else { return false }
        let nums: Set<Character> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        return Set(self).isSubset(of: nums)
    }
    
    var isAlpha: Bool {
        return !isEmpty && range(of: "[^a-zA-Z]", options: .regularExpression) == nil
    }
    
    var isCheckNumeric: Bool {
        return !isEmpty && range(of: "[^a-zA-Z]", options: .regularExpression) == nil
    }
    
    func validateName() -> Bool {
        do {
            if !(try self.isAlphaSpace()) {
                return false
            }
        } catch {
            return false
        }
        
        if self.isEmpty {
            return false
        }
        
        return true
    }
    
    func isAlphaSpace() throws -> Bool {
        let regex = try NSRegularExpression(pattern: "^[A-Za-z ]*$", options: [])
        return regex.firstMatch(in: self, options: [], range: NSMakeRange(0, self.count)) != nil
    }
    
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [NSAttributedString.DocumentReadingOptionKey.documentType:  NSAttributedString.DocumentType.html], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
    
//    func toDateString( inputDateFormat inputFormat  : String,  ouputDateFormat outputFormat  : String ) -> String
//    {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = inputFormat
//        let date = dateFormatter.date(from: self)
//        dateFormatter.dateFormat = outputFormat
//        dateFormatter.locale = NSLocale(localeIdentifier: "ENGLISH_LANG_CODE") as Locale?
//        return dateFormatter.string(from: date!)
//    }
//    
//    func toDateStringWithLocalisation( inputDateFormat inputFormat  : String,  ouputDateFormat outputFormat  : String ) -> String
////    {
////        let dateFormatter = DateFormatter()
////        dateFormatter.dateFormat = inputFormat
////        let date = dateFormatter.date(from: self)
////        dateFormatter.dateFormat = outputFormat
////        dateFormatter.locale = NSLocale(localeIdentifier: Utility.getSaveLanguage() ?? "ENGLISH_LANG_CODE") as Locale?
////        return dateFormatter.string(from: date!)
////    }
    
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
    
    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return String(self[fromIndex...])
    }
    
    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return String(self[..<toIndex])
    }
    
    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return String(self[startIndex..<endIndex])
    }
    
    func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    func removingWhitespaces() -> String {
        return components(separatedBy: .whitespaces).joined()
    }
    
    
    func isValidPhoneNumber() -> Bool {
        let regEx = "^\\+(?:[0-9]?){6,14}[0-9]$"
        
        let phoneCheck = NSPredicate(format: "SELF MATCHES[c] %@", regEx)
        return phoneCheck.evaluate(with: self)
    }
}
extension Utility {
    class func getEncodeString(string: String) -> String {
        let utf8str = string.data(using: String.Encoding.utf8)
        let base64Encoded = utf8str?.base64EncodedData()
        
        let base64Decoded = NSString(data: base64Encoded!, encoding: String.Encoding.utf8.rawValue)
        
        return base64Decoded! as String
    }
    
    class func getDecodedString(encodedString: String) -> String {
        if(Data(base64Encoded: encodedString) != nil)
        {
            let decodedData = Data(base64Encoded: encodedString)!
            let decodedString = String(data:decodedData, encoding: .utf8)!
            
            return decodedString
        }
        return encodedString
    }
    
    class func encode(_ s: String) -> String {
        let data = s.data(using: .nonLossyASCII, allowLossyConversion: true)!
        return String(data: data, encoding: .utf8)!
    }
    
    class func decode(_ s: String) -> String? {
        let data = s.data(using: .utf8)!
        return String(data: data, encoding: .nonLossyASCII)
    }
   
}

extension String {

  func CGFloatValue() -> CGFloat? {
    guard let doubleValue = Double(self) else {
      return nil
    }

    return CGFloat(doubleValue)
  }
}
extension URL {
    func fileSize() -> Double {
        var fileSize: Double = 0.0
        var fileSizeValue = 0.0
        try? fileSizeValue = (self.resourceValues(forKeys: [URLResourceKey.fileSizeKey]).allValues.first?.value as! Double?)!
        if fileSizeValue > 0.0 {
            fileSize = (Double(fileSizeValue) / (1024 * 1024))
        }
        return fileSize
    }
}
extension String {
    func toDouble() -> Double {
        return NumberFormatter().number(from: self)?.doubleValue ?? 0.0
    }
}
extension String {
    var isValidURL: Bool {
        guard !isEmpty, !trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return false
        }
        
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
            let matches = detector.matches(in: self,
                                           options: [],
                                           range: NSRange(location: .zero, length: utf16.count))
            return !matches.isEmpty
        } catch {
            return false
        }
    }
}

extension Character {
    var isNumber: Bool {
        return self >= "0" && self <= "9"
    }
}
