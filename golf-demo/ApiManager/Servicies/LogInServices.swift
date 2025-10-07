//
//  LogInServices.swift
//  skai-fitness
//
//  Created by iMac on 20/12/24.
//

import Foundation

class LogInServices{
    
    static let shared = { LogInServices() }()
    
    // User Login
    func login(parameters : [String : Any] = [:], success : @escaping(Int, Response) -> (), failure : @escaping(String) -> ()){
        APIManager.shared.requestAPIWithParameters(method: .post, urlString: loginURL, parameters: parameters) { (statusCode, response) in
            success(statusCode,response)
        } failure: { (error) in
            failure(error)
        }
    }
    
    // User SignUp
    func signUp(parameters : [String : Any] = [:], success : @escaping(Int, Response) -> (), failure : @escaping(String) -> ()){
        APIManager.shared.requestAPIWithParameters(method: .post, urlString: signUpURL, parameters: parameters) { (statusCode, response) in
            success(statusCode,response)
        } failure: { (error) in
            failure(error)
        }
    }
    
    // User Login
//    func sendOtp(parameters : [String : Any] = [:], success : @escaping(Int, Response) -> (), failure : @escaping(String) -> ()){
//        APIManager.shared.requestAPIWithParameters(method: .post, urlString: sendOtpURL, parameters: parameters) { (statusCode, response) in
//            success(statusCode,response)
//        } failure: { (error) in
//            failure(error)
//        }
//    }
    
    // Otp Verify
    func verifyEmail(parameters : [String : Any] = [:], success : @escaping(Int, Response) -> (), failure : @escaping(String) -> ()){
        APIManager.shared.requestAPIWithParameters(method: .post, urlString: otpVerifyURL, parameters: parameters) { (statusCode, response) in
            success(statusCode,response)
        } failure: { (error) in
            failure(error)
        }
    }
    
}
