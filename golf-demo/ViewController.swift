//
//  ViewController.swift
//  golf-demo
//
//  Created by Laxmansinh Rajpurohit on 24/09/25.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.goToNextScreen()
    }
    
    
    func goToNextScreen(){
        if Utility.getUserData() != nil {
            let golfCourseListVC = GolfCourseListViewController()
            self.navigationController?.pushViewController(golfCourseListVC, animated: true)
        }else{
            let vc = STORYBOARD.auth.instantiateViewController(withIdentifier: "LoginScreen") as! LoginScreen
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
