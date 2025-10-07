//
//  IndicatorLoader.swift
//  InTouch
//
//  Created by Nikunj Vaghela on 23/06/23.
//

import Foundation
import UIKit

class ScreenIndicatorLoader: UIView{
    static let shared = ScreenIndicatorLoader()
    
    var loadingIndicator = UIActivityIndicatorView()
    var backgroundView = UIView()
    var mainView = UIView()
    
    func showLoader(view: UIView){
        self.hideLoader()
        self.mainView = view
        
        self.backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        self.backgroundView.backgroundColor = .black.withAlphaComponent(0.38)
        self.backgroundView.isHidden = false
        appDelegate.window?.addSubview(self.backgroundView)
        
        self.loadingIndicator.style = UIActivityIndicatorView.Style.medium
        self.loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: (self.backgroundView.frame.width / 2) - 40, y: (self.backgroundView.frame.height / 2) - 40, width: 80, height: 80))
        self.loadingIndicator.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        self.loadingIndicator.color = UIColor.white
        self.backgroundView.addSubview(self.loadingIndicator)
        
        self.loadingIndicator.isHidden = false
        self.loadingIndicator.startAnimating()
        self.loadingIndicator.hidesWhenStopped = true
                
        appDelegate.window?.isUserInteractionEnabled = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.loadingIndicator.frame = CGRect(x: (self.backgroundView.frame.width / 2) - 40, y: (self.backgroundView.frame.height / 2) - 40, width: 80, height: 80)
        self.backgroundView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
    }
    
    func hideLoader(){
        self.loadingIndicator.stopAnimating()
        self.backgroundView.removeFromSuperview()
        appDelegate.window?.isUserInteractionEnabled = true
    }
}
