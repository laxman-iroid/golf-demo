//
//  Utility.swift
//  skai-fitness
//
//  Created by iMac on 04/12/24.
//

import UIKit
import NotificationBannerSwift
import AVFoundation
import AVKit

class Utility: NSObject {
    
    class func saveUserData(data: [String: Any]){
        UserDefaults.standard.setValue(data, forKey: USER_DATA)
    }
    
    class func getUserData() -> LogInResponse? {
        if let data = UserDefaults.standard.value(forKey: USER_DATA) as? [String: Any]{
            let dic = LogInResponse(JSON: data)
            return dic
        }
        return nil
    }
    
    class func getAccessToken() -> String?{
        if let token = getUserData()?.token?.token {
            return token
        }
        return nil
    }
    
    class func removeUserData(){
        UserDefaults.standard.removeObject(forKey: USER_DATA)
    }
    
    class func saveAgeData(){
        
    }
    
    private static let fcmTokenKey = "FCM_TOKEN"
    
    /// Save FCM token to UserDefaults
    static func saveFCMToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: fcmTokenKey)
        UserDefaults.standard.synchronize()
    }
    
    /// Retrieve FCM token from UserDefaults
    static func getFCMToken() -> String? {
        return UserDefaults.standard.string(forKey: fcmTokenKey)
    }
    
    /// Check if FCM token exists
    static func hasFCMToken() -> Bool {
        return getFCMToken() != nil
    }
    
    /// Remove FCM token from UserDefaults
    static func removeFCMToken() {
        UserDefaults.standard.removeObject(forKey: fcmTokenKey)
        UserDefaults.standard.synchronize()
    }

    
    class func getUIcolorfromHex(hex:String) -> UIColor {
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
    
    class func createURLStringWithParams(baseURL: String, params: [String: Any?]) -> String {
        var convertURL: String = ""
        guard var components = URLComponents(string: baseURL) else {
            return ""
        }
        
        // Create query items from parameters
        var queryItems = [URLQueryItem]()
        for (key, value) in params {
            if let value = value {
                queryItems.append(URLQueryItem(name: key, value: value as? String))
            }
        }
        
        components.queryItems = queryItems
        convertURL = components.url?.absoluteString ?? ""
        return convertURL
    }
    
    class func gotoAppSettings() {
        
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
            }
            else {
                UIApplication.shared.openURL(settingsUrl)
            }
        }
    }
    
    class func isEmailValid(emailStr :String?) -> Bool{
        guard let email:String = emailStr else { return false }
        let emailPattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}" //"[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
        do{
            let regex = try NSRegularExpression(pattern: emailPattern, options: .caseInsensitive)
            let foundPatters = regex.numberOfMatches(in: email, options: .anchored, range: NSRange(location: 0, length: email.count))
            if foundPatters > 0 {
                return true
            }
        }catch{
            //error
        }
        return false
    }
    
    class func getLastSixDaysInitials() -> [String] {
        var dayInitials: [String] = []
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE" // Full name of the day
        
        // Get the current date
        let calendar = Calendar.current
        let today = Date()
        
        // Loop through the last 7 days
        for offset in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -offset, to: today) {
                let dayName = dateFormatter.string(from: date)
                if let firstCharacter = dayName.first {
                    dayInitials.append(String(firstCharacter))
                }
            }
        }
        
        return dayInitials
    }
    
    class func setUpNSMutableAttributedLabel(textLabel: UILabel, firstTextValue: String, secondTextValue: String, firstTextFont: UIFont, secondTextFont: UIFont, isSecondTextInNewLine: Bool){
        let attributedText = NSMutableAttributedString()
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        attributedText.append(NSAttributedString(string: "\(firstTextValue)", attributes: [.font: firstTextFont]))
        attributedText.append(NSAttributedString(string: isSecondTextInNewLine ? "\n/\(secondTextValue)" : "/\(secondTextValue)", attributes: [.font: secondTextFont]))
        textLabel.attributedText = attributedText
    }
    
    //MARK: reachability
    class func isInternetAvailable() -> Bool {
        var  isAvailable : Bool
        isAvailable = true
        let reachability = try? Reachability() //try? Reachability(hostname: "google.com") //Reachability()
        if(reachability?.connection == Reachability.Connection.unavailable)
        {
            isAvailable = false
        }
        else
        {
            isAvailable = true
        }
        return isAvailable
    }
    
    class func setLoginRoot() {
        let vc = STORYBOARD.main.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        let navVC = UINavigationController(rootViewController: vc)
        navVC.interactivePopGestureRecognizer?.isEnabled = false
        navVC.navigationBar.isHidden = true
        appDelegate.window?.rootViewController = navVC
        appDelegate.window?.makeKeyAndVisible()
    }
    
//    class func setImage(_ imageUrl: String!, imageView: UIImageView!, placeHolderType:Int = 1) {
//    
//        var placeHolderImage = "img_profile_placeholder"
//        
//        if placeHolderType == 2{
//            placeHolderImage = "img_placeholder"
//        }
//        
//        if imageUrl != nil && !(imageUrl == "") {
//            imageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
//            //            imageView.sd_setShowActivityIndicatorView(true)
//            //            imageView.sd_setIndicatorStyle(.gray)
//            imageView!.sd_setImage(with: URL(string: imageUrl.replacingOccurrences(of: " ", with: "%20") ), placeholderImage: UIImage(named: placeHolderImage))
//        }
//        else
//        {
//            //               let circleAvatarImage = LetterAvatarMaker()
//            //                   .setCircle(true)
//            //                   .setUsername(name?.uppercased() ?? "")
//            //                   .setBorderWidth(1.0)
//            //                   .setBackgroundColors([ .random ])
//            //                   .build()
//            //               imageView.image = circleAvatarImage
//            imageView?.image = UIImage(named: placeHolderImage)
//        }
//    }
    
    // MARK: - For compress image
    class func getCompressedImageData(_ originalImage: UIImage?) -> Data? {
        // UIImage *largeImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        let largeImage = originalImage
        
        var compressionRatio: Double = 0.5
        var resizeAttempts = 3
        var imgData = largeImage?.jpegData(compressionQuality: CGFloat(compressionRatio))
        print(String(format: "Starting Size: %lu", UInt(imgData?.count ?? 0)))
        
        if imgData!.count > 1000000 {
            resizeAttempts = 4
        } else if imgData!.count > 400000 && imgData!.count <= 1000000 {
            resizeAttempts = 2
        } else if imgData!.count > 100000 && imgData!.count <= 400000 {
            resizeAttempts = 2
        } else if imgData!.count > 40000 && imgData!.count <= 100000 {
            resizeAttempts = 1
        } else if imgData!.count > 10000 && imgData!.count <= 40000 {
            resizeAttempts = 1
        }
        print("resizeAttempts \(resizeAttempts)")
        //Trying to push it below around about 0.4 meg
        //while ([imgData length] > 400000 && resizeAttempts > 0) {
        while resizeAttempts > 0 {
            
            resizeAttempts -= 1
            
            print("Image was bigger than 400000 Bytes. Resizing.")
            print(String(format: "%i Attempts Remaining", resizeAttempts))
            
            //Increase the compression amount
            compressionRatio = compressionRatio * 0.8
            print("compressionRatio \(compressionRatio)")
            
            //Test size before compression
            //            print(String(format: "Current Size: %lu", UInt(imgData.c)))
            imgData = largeImage!.jpegData(compressionQuality: CGFloat(compressionRatio))
            
            //Test size after compression
            //            print(String(format: "New Size: %lu", UInt(imgData.length())))
            
        }
        
        //Set image by comprssed version
        let savedImage = UIImage(data: imgData!)
        //Check how big the image is now its been compressed and put into the UIImageView
        // *** I made Change here, you were again storing it with Highest Resolution ***
        let endData = savedImage!.jpegData(compressionQuality: CGFloat(compressionRatio))
        //NSData *endData = UIImagePNGRepresentation(savedImage);
        
        print(String(format: "Ending Size: %lu", UInt(endData?.count ?? 0)))
        
        return endData
    }
    
    // MARK: - Date To String 
   class func dateToString(Formatter: String, date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Formatter
        let FinalDate:String = dateFormatter.string(from: date)
        return FinalDate
    }
    
    // MARK: - Calculate Label Width
    class func labelWidth(font: UIFont ,height: CGFloat,text: String) -> CGFloat {
        let label =  UILabel(frame: CGRect(x: 0, y: 0, width: .greatestFiniteMagnitude, height: height))
        label.numberOfLines = 0
        label.text = text
        label.font = font//UIFont(name: "Outfit-Medium", size: 16)
        label.sizeToFit()
        return label.frame.width
    }
    
    class func labelWidthWithoutFont(height: CGFloat,text: String) -> CGFloat {
        let label =  UILabel(frame: CGRect(x: 0, y: 0, width: .greatestFiniteMagnitude, height: height))
        label.numberOfLines = 0
        label.text = text
        label.font = UIFont(name: "Outfit-Regular", size: 16)
        label.sizeToFit()
        return label.frame.width
    }
    
    // MARK: - phone number is valid or not
    class func isValidPhoneNumber(phone: String) -> Bool {
        let phoneRegex = "^[0-9+]{0,1}+[0-9]{9,14}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phoneTest.evaluate(with: phone)
    }
    
    // MARK: - phone number is Limitation
    class func isPhoneNumberDigit(phone: String) -> Bool {
        let checkDigit = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let firstDigit = checkDigit.first else {
            return false
        }
        if firstDigit == "5" {
            return checkDigit.count == 9 && checkDigit.allSatisfy({ $0.isNumber })
        } else if firstDigit == "0" {
            return checkDigit.count == 10 && checkDigit.allSatisfy({ $0.isNumber } )
        }
        
        return false
    }
    
    // MARK: - Localization function
    class func getCurrentLanguage() -> String{
        let userdef = UserDefaults.standard
        let langArray = userdef.object(forKey: "AppleLanguages") as! NSArray
        let current = langArray.firstObject as! String
        return current
    }
    
//    class func setLanguage(langStr:String){
//        let defaults = UserDefaults.standard
//        defaults.set([langStr], forKey: "AppleLanguages")
//        defaults.synchronize()
//        Bundle.setLanguage(langStr)
//    }
    
    class func setLocalizedValuesforView(parentview: UIView ,isSubViews : Bool) {
        if parentview is UILabel {
            let label = parentview as! UILabel
            let titleLabel = label.text
            if titleLabel != nil {
                label.text = self.getLocalizdString(value: titleLabel!)
            }
        }
        else if parentview is UIButton {
            let button = parentview as! UIButton
            let titleLabel = button.title(for:.normal)
            if titleLabel != nil {
                button.setTitle(self.getLocalizdString(value: titleLabel!), for: .normal)
            }
        }
        else if parentview is UITextField {
            let textfield = parentview as! UITextField
            let titleLabel = textfield.text!
            //               if(titleLabel == "")
            //               {
            let placeholdetText = textfield.placeholder
            if(placeholdetText != nil)
            {
                textfield.placeholder = self.getLocalizdString(value:placeholdetText!)
            }
            
            //                   return
            //               }
            textfield.text = self.getLocalizdString(value:titleLabel)
        }
        else if parentview is UITextView {
            let textview = parentview as! UITextView
            let titleLabel = textview.text!
            textview.text = self.getLocalizdString(value:titleLabel)
        }
        if(isSubViews)
        {
            for view in parentview.subviews {
                self.setLocalizedValuesforView(parentview:view, isSubViews: true)
            }
        }
    }
    class func getLocalizdString(value: String) -> String {
            var str = ""
            let language = self.getCurrentLanguage()
            let path = Bundle.main.path(forResource: language, ofType: "lproj")
            if(path != nil)
            {
                let languageBundle = Bundle(path:path!)
                str = NSLocalizedString(value, tableName: nil, bundle: languageBundle!, value: value, comment: "")
            }
            return str
        }
    
//    class func getColour() -> [ThemeModel] {
//        if let savedData = UserDefaults.standard.data(forKey: "COLOUR_THEME") {
//            let decoder = JSONDecoder()
//            if let loadedThemes = try? decoder.decode([ThemeModel].self, from: savedData) {
//                return loadedThemes
//            }
//        }
//        return []
//    }
    
    // MARK: - Save and get profile theme data -
//    class func saveThemesToUserDefaults(themes: [ThemeModel]) {
//        let encoder = JSONEncoder()
//        if let encodedData = try? encoder.encode(themes) {
//            UserDefaults.standard.set(encodedData, forKey: "COLOUR_THEME")
//        }
//    }
    
    class func timeStempformanagedata(timestamp: String, dateFormate:String = "MMM d, YYYY") -> String { // Timestamp in milliseconds to Date in 3 fomet
        let date = NSDate(timeIntervalSince1970: Double(timestamp) ?? 0.00)

        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.dateFormat = "MMM dd YYYY hh:mm a"

        let dateString = dayTimePeriodFormatter.string(from: date as Date)
        var finalDate: String?
        let dateFormatter = DateFormatter()                      // Date
            dateFormatter.dateFormat = dateFormate
            finalDate = dateFormatter.string(from: date as Date)
        return finalDate ?? ""
    }
    
    class func getThumbnailImage(videoStringUrl: String, success: @escaping (CGImage) -> Void) {
        guard let videoURL = URL(string: videoStringUrl) else {
            print("Invalid video URL string")
            return
        }
        
        // Generate a thumbnail from the video URL
        let asset = AVAsset(url: videoURL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        // Get the thumbnail image
        imageGenerator.generateCGImagesAsynchronously(forTimes: [NSValue(time: CMTimeMake(value: 0, timescale: 1))]) { _, image, _, result, error in
            if let error = error {
                print("Error generating thumbnail: \(error)")
                return
            }
            
            if let image = image {
                DispatchQueue.main.async {
                    // Assign thumbnail to appropriate image view
                    // self.theController.mainView.videoImageView.image = UIImage(cgImage: image)
                    success(image)
                }
            }
        }
    }
    
    class func playVideo(videoUrlString: String, viewController: UIViewController) {
        guard let url = URL(string: videoUrlString) else {
            print("Invalid URL")
            return
        }
        
        let player = AVPlayer(url: url)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        
        // Present the player view controller
        viewController.present(playerViewController, animated: true) {
            player.play()
        }
    }
    
    
//    class func setSvgImage(_ imageUrl: String!, imageView: UIImageView!) {
//            guard let urlString = imageUrl, !urlString.isEmpty else {
//                if let placeholder = UIImage(named: "image_placeholder") {
//                    imageView?.image = placeholder
//                }
//                return
//            }
//            
//            imageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
//            
//            let completion: SDExternalCompletionBlock = { image, error, cacheType,arg  in
//                if let img = image {
//                    // Use tinted() extension instead of relying on tintColor
////                    imageView.image = img.tinted(with: )
//                }
//            }
//            
//            if urlString.contains(".svg") {
//                imageView.sd_setImage(
//                    with: URL(string: urlString),
//                    placeholderImage: UIImage(named: "image_placeholder"),
//                    options: [],
//                    context: [.imageCoder: CustomSVGDecoder(fallbackDecoder: SDImageSVGCoder.shared)],
//                    progress: nil,
//                    completed: completion
//                )
//            } else {
//                imageView.sd_setImage(
//                    with: URL(string: urlString),
//                    placeholderImage: UIImage(named: "image_placeholder"),
//                    options: [],
//                    context: nil,
//                    progress: nil,
//                    completed: completion
//                )
//            }
//        }
    
    
    class func timeString(from timeInterval: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timeInterval) // seconds since 1970
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"   // 12-hour format with AM/PM
        return formatter.string(from: date)
    }
    
}
