//
//  Constant.swift
//  skai-fitness
//
//  Created by iMac on 04/12/24.
//

import Foundation
import UIKit
import NotificationBannerSwift

//MARK: - Global Variables
let APPLICATION_NAME = "fore golf"
var banner: NotificationBanner?
var growingBanner: GrowingNotificationBanner?
let isAppInTestMode = true // true or false
var COUNTRY_CODE = "+972"

enum VerifyOTPTypes : Int {
    case registrationOTP = 1
    case resetPasswordOTP = 2
}

enum ExploreReelType : Int {
    case products = 1
    case professional = 2
}

enum TermsAndPolicyType : Int {
    case terms = 1
    case policy = 2
}

enum favoriteFilterType : Int {
    case products = 2
    case professional = 3
}

enum SpecialAndSeasonal : Int {
    case seasonal = 7
    case special = 8
}

enum HomeCategoryType: Int {
    case product = 1
    case store = 2
    case professional = 3
}

enum PoliciesAndTermsType: Int{
    case policies = 1
    case termsOfUse = 2
}

// MARK: - Session Key
let USER_DATA = "user_data"
let USER_DETAILS = "user_details"

var screenWidth: CGFloat{
    return UIScreen.main.bounds.width
}

var screenHeight: CGFloat{
    return UIScreen.main.bounds.height
}

var bottomSafeArea: CGFloat{
    if #available(iOS 11.0, *) {
        let window = UIApplication.shared.keyWindow
        return window?.safeAreaInsets.bottom ?? 0
    }
    return 0
}

var topSafeArea: CGFloat{
    if #available(iOS 11.0, *) {
        let window = UIApplication.shared.keyWindow
        return window?.safeAreaInsets.top ?? 0
    }
    return 0
}

let appDelegate = UIApplication.shared.delegate as! AppDelegate


//MARK:- Storyboards
struct STORYBOARD {
    static let main = UIStoryboard(name: "Main", bundle: Bundle.main)
    static let tabBar = UIStoryboard(name: "TabBar", bundle: Bundle.main)
    static let auth = UIStoryboard(name: "Auth", bundle: Bundle.main)
    static let home = UIStoryboard(name: "Home", bundle: Bundle.main)
    static let test = UIStoryboard(name: "Test", bundle: Bundle.main)
    static let product = UIStoryboard(name: "ProductItem", bundle: Bundle.main)
    static let cart = UIStoryboard(name: "Cart", bundle: Bundle.main)
    static let explore = UIStoryboard(name: "Explore", bundle: Bundle.main)
    static let profile = UIStoryboard(name: "Profile", bundle: Bundle.main)
    static let message = UIStoryboard(name: "Message", bundle: Bundle.main)
    static let visitProfile = UIStoryboard(name: "VisitProfile", bundle: Bundle.main)
}

func getFileName() -> String{
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyyMMddHHmmssZ"
    return dateFormatter.string(from: Date())
}

