//
//  ApiManager.swift
//  Miracle-Mindset
//
//  Created by iMac on 29/01/24.
//
import Foundation
import AlamofireObjectMapper
import Alamofire
import Network

class APIManager {
    
    static let shared = { APIManager(baseURL: serverUrl) }()
    
    var baseURL: URL?
    
    required init(baseURL: String) {
        self.baseURL = URL(string: baseURL)
    }
    
    func getHeader() -> HTTPHeaders {
        
        var headerDic: HTTPHeaders = [:]
        
        if Utility.getUserData() == nil {
            headerDic = [ "Accept": "application/json"]
        }
        else {
            if let accessToken = Utility.getAccessToken() {
                headerDic = [
                    "Authorization":"Bearer "+accessToken,
                    "Accept": "application/json"
                ]
            }
            else {
                headerDic = ["Accept": "application/json"]
            }
        }
        return headerDic
    }
    
    func isConnectedToNetwork()->Bool{
        return NetworkReachabilityManager()!.isReachable
    }
    
    func requestAPIWithParameters(method: HTTPMethod,urlString: String,parameters: [String:Any],success: @escaping(Int,Response) -> (),failure : @escaping(String) -> ()){
        
        guard Utility.isInternetAvailable() else {
            failure("No internet connection available.")
            return
        }
            
        if isAppInTestMode {
            print("====================================================")
            print("Headers : ", getHeader())
            print("------")
            print("Method : ", method)
            print("------")
            print("UrlString : ", urlString)
            print("------")
            print("Parameters : ", parameters)
            print("------")
        }
        
        Alamofire.request(urlString, method: method, parameters: parameters, encoding: JSONEncoding.default, headers: getHeader()).responseObject { (response: DataResponse<Response>) in
            
            if isAppInTestMode {
                print("Response value : ", response.value?.toJSON() as Any)
                print("------")
                print("Response result : ", response.result.value?.toJSON() as Any)
                print("------")
                print("Response failure : ", failure)
                print("====================================================")
            }
            
            switch response.result {
            case .success(let value):
                guard let statusCode = response.response?.statusCode else {
                    failure(value.message ?? "")
                    return
                }
                if (200..<300).contains(statusCode) {
                    success(statusCode,value)
                }
                else if statusCode == 401 {
                    if  urlString != loginURL{
                        Utility.removeUserData()
                        Utility.setLoginRoot()
                    }
                    failure(value.message ?? "")
                }else if statusCode == 402{
                    failure(value.message ?? "")
                }else if statusCode == 403{
                    success(statusCode,value)
                }else{
                    failure(value.message ?? "")
                }
                break
            case .failure(let error):
                failure(error.localizedDescription)
                break
            }
        }
    }
    
    func requestAPIWithGetMethod(parameters: [String: Any] = [:],method: HTTPMethod,urlString: String,success: @escaping(Int,Response) -> (),failure : @escaping(String) -> ()){
        
        if isAppInTestMode {
            print("====================================================")
            print("Headers : ", getHeader())
            print("------")
            print("Method : ", method)
            print("------")
            print("UrlString : ", urlString)
            print("------")
        }
        
        guard Utility.isInternetAvailable() else {
            failure("No internet connection available.")
            return
        }
        
        Alamofire.request(urlString, method: method, parameters: parameters, encoding: URLEncoding.default, headers: getHeader()).responseObject { (response: DataResponse<Response>) in
            
            if isAppInTestMode {
                print("Response value : ", response.value?.toJSON())
                print("------")
                print("Response result : ", response.result.value?.toJSON())
                print("------")
                print("Response failure : ", failure)
                print("====================================================")
            }
            
            switch response.result{
            case .success(let value):
                guard let statusCode = response.response?.statusCode else {
                    failure(value.message ?? "")
                    return
                }
                if (200..<300).contains(statusCode){
                    success(statusCode,value)
                }else if statusCode == 401{
                    Utility.removeUserData()
                    Utility.setLoginRoot()
                    failure(value.message ?? "")
                }else if statusCode == 402{
                    failure(value.message ?? "")
                }else if statusCode == 403{
                    success(statusCode,value)
                }else{
                    failure(value.message ?? "")
                }
                break
            case .failure(let error):
                failure(error.localizedDescription)
                break
            }
        }
    }
    
    
    func requestAPIWithQueryParameterMethod(method: HTTPMethod,urlString: String,parameters: [String:Any] ,success: @escaping(Int,Response) -> (),failure : @escaping(String) -> ()){

        if isAppInTestMode {
            print("====================================================")
            print("Headers : ", getHeader())
            print("------")
            print("Method : ", method)
            print("------")
            print("UrlString : ", urlString)
            print("------")
        }

        guard Utility.isInternetAvailable() else {
            failure("No internet connection available.")
            return
        }

        Alamofire.request(urlString, method: method, parameters: parameters, encoding: URLEncoding.default, headers: getHeader()).responseObject { (response: DataResponse<Response>) in

            if isAppInTestMode {
                print("Response value : ", response.value?.toJSON() as Any)
                print("------")
                print("Response result : ", response.result.value?.toJSON() as Any)
                print("------")
                print("Response failure : ", failure)
                print("====================================================")
            }

            switch response.result{
            case .success(let value):
                guard let statusCode = response.response?.statusCode else {
                    failure(value.message ?? "")
                    return
                }
                if (200..<300).contains(statusCode){
                    success(statusCode,value)
                }else if statusCode == 401{
                    Utility.removeUserData()
                    Utility.setLoginRoot()
                    failure(value.message ?? "")
                }else if statusCode == 402{
                    failure(value.message ?? "")
                }else if statusCode == 403{
                    success(statusCode,value)
                }else{
                    failure(value.message ?? "")
                }
                break
            case .failure(let error):
                failure(error.localizedDescription)
                break
            }
        }
    }

    // Send message to chatbot
    func sendChatBotMessage(message: String, success: @escaping ([String: Any]) -> (), failure: @escaping (String) -> ()) {

        // Get bundle identifier
        let bundleId = "com.golocal.user.mobile.app"

        // Prepare headers
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Origin": bundleId
        ]

        // Prepare parameters
        let parameters: [String: Any] = [
            "message": message
        ]

        if isAppInTestMode {
            print("====================================================")
            print("ChatBot URL: \(chatBotUrl)")
            print("------")
            print("Headers: \(headers)")
            print("------")
            print("Parameters: \(parameters)")
            print("------")
        }

        Alamofire.request(chatBotUrl, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in

            if isAppInTestMode {
                print("Response: \(response.result.value ?? "No response")")
                print("====================================================")
            }

            switch response.result {
            case .success(let value):
                guard let statusCode = response.response?.statusCode else {
                    failure("No response from server")
                    return
                }

                if (200..<300).contains(statusCode) {
                    if let json = value as? [String: Any] {
                        success(json)
                    } else {
                        failure("Invalid response format")
                    }
                } else {
                    if let json = value as? [String: Any], let message = json["message"] as? String {
                        failure(message)
                    } else {
                        failure("Request failed with status code: \(statusCode)")
                    }
                }

            case .failure(let error):
                failure(error.localizedDescription)
            }
        }
    }

    func requestWithImage(urlString : String,method: HTTPMethod? = .post, imageParameterName : String,images : Data?, videoParameterName: String, videoData : Data?, audioParameterName : String, audioData : Data?, bgThumbnailParameter : String, bgThumbImage : Data?, videoPreviewParameter : String, videoPreview : Data?, parameters : [String:Any],success : @escaping(Int,Response) -> (),failure : @escaping(String) -> ()){
        
        guard Utility.isInternetAvailable() else {
            failure("No internet connection available.")
            return
        }
        if isAppInTestMode {
            print("====================================================")
            print("url ----> ", urlString)
            print("------")
            print("parameters ----> ", parameters)
            print("------")
            print("headers ----> ", getHeader())
            print("------")
        }
        
        Alamofire.upload(multipartFormData:{(multipartFormData) in
            
            if let image = images {
                multipartFormData.append(image, withName: imageParameterName,fileName: getFileName()+".jpg", mimeType: "image/jpg")
            }
            
            if let thumbImage = bgThumbImage {
                multipartFormData.append(thumbImage, withName: bgThumbnailParameter,fileName: getFileName()+".jpg", mimeType: "image/jpg")
            }
            
            if let video = videoData{
                //                do {
                //                    let data = try Data(contentsOf: video, options: .mappedIfSafe)
                //                    print(data)
                multipartFormData.append(video, withName: videoParameterName, fileName: getFileName()+".mp4", mimeType: "video/mp4")
                //                } catch  {
                //                }
                /*
                if let thumbImage = bgThumbImage{
                    multipartFormData.append(thumbImage, withName: bgThumbnailParameter,fileName: getFileName()+".jpg", mimeType: "image/jpg")
                }
                */
                
                if let videoPreviewGIF = videoPreview {
                    multipartFormData.append(videoPreviewGIF, withName: videoPreviewParameter,fileName: getFileName()+".gif", mimeType: "image/gif")
                }
            }
            if let audio = audioData{
                //                do {
                //                    let data = try Data(contentsOf: audio)
                //                    print(data)
                multipartFormData.append(audio, withName: audioParameterName, fileName: getFileName()+".mp3", mimeType: "audio/m4a")
                //                } catch  {
                //                }
            }
            for (key, value) in parameters {
                multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
            }
            
            print("Multipart form data parameters", parameters)
            
        }, to:urlString,method: method!,headers:getHeader()){ (result) in
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    print("Upload Progress: \(progress.fractionCompleted)")
                    //                    SVProgressHUD.showProgress(Float(progress.fractionCompleted), status: "Uploading...")
                })
                
                upload.responseObject { (response: DataResponse<Response>) in
                    
                    if isAppInTestMode {
                        print("Response value : ", response.value?.toJSON())
                        print("------")
                        print("Response result : ", response.result.value?.toJSON())
                        print("------")
                        print("Response failure : ", failure)
                        print("====================================================")
                    }
                    
                    switch response.result{
                    case .success(let value):
                        guard let statusCode = response.response?.statusCode else {
                            failure(value.message ?? "")
                            return
                        }
                        
                        print("response ----> ", response.result.value?.toJSON() as Any)
                        if (200..<300).contains(statusCode){
                            success(statusCode,value)
                        }else if statusCode == 401{
                            Utility.removeUserData()
                            Utility.setLoginRoot()
                        }else if statusCode == 402{
                            failure(value.message ?? "")
                        }else if statusCode == 403{
                            success(statusCode,value)
                        }else{
                            failure(value.message ?? "")
                        }
                        break
                    case .failure(let error):
                        failure(error.localizedDescription)
                        break
                    }
                    
                }
            case .failure(let error):
                failure(error.localizedDescription)
            }
        }
    }
    
    
}
