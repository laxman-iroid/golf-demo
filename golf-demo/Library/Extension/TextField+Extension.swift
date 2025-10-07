//
//  TextField+Extension.swift
//
//  Created by jay on 21/07/20.
//  Copyright © 2020 Vishal. All rights reserved.
//

import Foundation
import UIKit


extension UITextField {
    func addBottomBorder(){
        self.borderStyle = .none
        self.layer.backgroundColor = UIColor.white.cgColor
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0.0
    }
    
    func highlight(){
        if let view = self.superview as? dateSportView{
            view.borderColor = UIColor.white
        }
    }
    
    func unHighLight(){
        if let view = self.superview as? dateSportView{
            view.borderColor = UIColor(named: "border_color")
        }
    }
}
extension UITextView{
    func highlight(){
        if let view = self.superview as? dateSportView{
            view.borderColor = UIColor.white
        }
    }
    
    func unHighLight(){
        if let view = self.superview as? dateSportView{
            view.borderColor = UIColor(named: "border_color")
        }
    }
}
extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}
