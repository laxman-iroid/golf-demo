//
//  Double+Extension.swift

//
//   Created by Vishal on 30/09/21.
//  Copyright © 2020 Vishal. All rights reserved.
//

import Foundation
import UIKit

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
    func toString() -> String {
        return String(format: "%.1f",self)
    }
}

extension CGFloat {
    /// Rounds the double to decimal places value
    
    func toString() -> String {
        return String(format: "%.1f",self)
    }
}

extension Float {
    var cleanZeroBehindFloatValue: String {
       return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}

extension Data {
    func getSizeInMB() -> Double {
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useMB]
        bcf.countStyle = .file
        let string = bcf.string(fromByteCount: Int64(self.count)).replacingOccurrences(of: ",", with: ".")
        if let double = Double(string.replacingOccurrences(of: " MB", with: "")) {
            return double
        }
        return 0.0
    }
}
