//
//  SignUpScreen.swift
//  golf-demo
//
//  Created by Laxman Rajpurohit on 07/10/25.
//

import UIKit

class SignUpScreen: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: LoaderButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func onBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onSignUp(_ sender: UIButton) {
        self.checkValidation()
    }
    
    func checkValidation() {
        if self.nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).count == 0{
            Utility.showAlert(message: "Please enter name")
            return
        }else if self.emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).count == 0{
            Utility.showAlert(message: "Please enter email")
            return
        }else if !(Utility.isEmailValid(emailStr: self.emailTextField.text)){
            Utility.showAlert( message: "Please enter a valid email")
            return
        }else if self.passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).count == 0{
            Utility.showAlert(message: "Please enter password")
            return
        }else {
            self.signUpApi()
        }
    }
}

//MARK: - API Calling
extension SignUpScreen{
    
    //MARK: - SignUp
    func signUpApi() {
        if Utility.isInternetAvailable() {
            
            view?.endEditing(true)
//            self.signUpButton.isLoading = true
            let param = SignUpRequest(name: nameTextField.text ,email: emailTextField.text ?? "", password: passwordTextField.text ?? "")
            LogInServices.shared.signUp(parameters: param.toJSON()) { code, response in
//                self.signUpButton.isLoading = false
                if let data = response.logInResponse {
                    Utility.saveUserData(data: data.toJSON())
                    DispatchQueue.main.async {
                        let golfCourseListVC = GolfCourseListViewController()
                        self.navigationController?.pushViewController(golfCourseListVC, animated: true)
                    }
                }
            } failure: { error in
//                self.signUpButton.isLoading = false
                Utility.showAlert(message: error)
            }
        } else {
            ScreenIndicatorLoader.shared.hideLoader()
            Utility.showNoInternetConnectionAlertDialog()
        }
    }
}
