//
//  Alert.swift
//  HandyGolf
//
//  Created by iMac on 07/06/24.
//

import Foundation
import UIKit
import NotificationBannerSwift

extension Utility{
    
    class func showToast(message: String) {
//        appDelegate.window?.makeToast(message)
    }
    
    //MARK: Internet Alert
    class func showNoInternetConnectionAlertDialog() {
        let banner = NotificationBanner(title: APPLICATION_NAME, subtitle: "It seems you are not connected to the internet. Kindly connect and try again.", style: .danger)
            banner.autoDismiss = true
            banner.duration = 2.0
            banner.show()
    }
    
    
    // MARK: - Go to setting  for permission alert
    class func showPermissionAlert(vc : UIViewController, message : String) {
        
        let alertController = UIAlertController(title: "Permission Denied", message: message, preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (alertAction) in
            gotoAppSettings()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        DispatchQueue.main.async {
            vc.present(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK: - Notification Banner
    class func showAlert(message: String) {
        self.dismissPreviousBanner()
        DispatchQueue.main.async {
            growingBanner = GrowingNotificationBanner(title: APPLICATION_NAME, subtitle: message, style: .warning)
            growingBanner?.autoDismiss = true
            growingBanner?.duration = 2.0
            growingBanner?.show()
        }
    }
        
    class func successAlert(message: String){
        self.dismissPreviousBanner()
        DispatchQueue.main.async {
            banner = NotificationBanner(title: APPLICATION_NAME, subtitle: message, style: .success)
            banner?.autoDismiss = true
            banner?.duration = 2.0
            banner?.show()
        }
    }
    
    class func infoAlert(message: String){
        self.dismissPreviousBanner()
        DispatchQueue.main.async {
            banner = NotificationBanner(title: APPLICATION_NAME, subtitle: message, style: .info)
            banner?.autoDismiss = true
            banner?.duration = 2.0
            banner?.show()
        }
    }
    
    class func dismissPreviousBanner(){
        if banner != nil{
            banner?.dismiss()
        }
        if growingBanner != nil{
            growingBanner?.dismiss()
        }
    }
}
