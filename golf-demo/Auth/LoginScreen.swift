//
//  LoginScreen.swift
//  golf-demo
//
//  Created by Laxman Rajpurohit on 07/10/25.
//

import UIKit

class LoginScreen: UIViewController {
    
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: LoaderButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func onLogin(_ sender: UIButton) {
        self.checkValidation()
    }
    
    @IBAction func onSignup(_ sender: UIButton) {
        self.goToNextScreen()
    }
    
    func goToNextScreen(){
        let vc = STORYBOARD.auth.instantiateViewController(withIdentifier: "SignUpScreen") as! SignUpScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func checkValidation() {
        if self.emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).count == 0{
            Utility.showAlert(message: "Please enter email")
            return
        }else if !(Utility.isEmailValid(emailStr: self.emailTextField.text)){
            Utility.showAlert( message: "Please enter a valid email")
            return
        }else if self.passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).count == 0{
            Utility.showAlert(message: "Please enter password")
            return
        }else {
            self.logInApi()
        }
    }
}

//MARK: - API Calling
extension LoginScreen{
    
    //MARK: - Login
    func logInApi() {
        if Utility.isInternetAvailable() {
            
            view?.endEditing(true)
            //            ScreenIndicatorLoader.shared.showLoader(view: self.view)
            self.loginButton.isLoading = true
            let param = LoginRequest(email: emailTextField.text ?? "", password: passwordTextField.text ?? "")
            LogInServices.shared.login(parameters: param.toJSON()) { code, response in
                //                ScreenIndicatorLoader.shared.hideLoader()
                self.loginButton.isLoading = false
                if let data = response.logInResponse {
                    Utility.saveUserData(data: data.toJSON())
                    
                    // Navigate to Golf Course List after successful login
                    DispatchQueue.main.async {
                        let golfCourseListVC = GolfCourseListViewController()
                        self.navigationController?.pushViewController(golfCourseListVC, animated: true)
                    }
                }
            } failure: { error in
                self.loginButton.isLoading = false
                Utility.showAlert(message: error)
            }
        } else {
            ScreenIndicatorLoader.shared.hideLoader()
            Utility.showNoInternetConnectionAlertDialog()
        }
    }
}
