//
//  MainViewController.swift
//  donationApp
//
//  Created by Natalia Sheila Cardoso de Siqueira on 08/03/17.
//  Copyright © 2017 PUC. All rights reserved.
//

import UIKit
import FacebookLogin

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let loginButton = UIButton(type: .custom)
        loginButton.backgroundColor = UIColor.darkGray
        loginButton.frame = CGRect(origin: CGPoint(x:0, y:0), size: CGSize(width: 180, height: 40))
        loginButton.center = view.center;
        loginButton.setTitle("Log in with Facebook", for: .normal)
        
    //    let loginButton = LoginButton(readPermissions: [ .publicProfile, .email ])
    //    loginButton.center = view.center

        //Handle clicks on the button
        loginButton.addTarget(self, action:#selector(loginButtonClicked), for: .touchUpInside)
        view.addSubview(loginButton)
    }
    
    @objc func loginButtonClicked() {
        let loginManager = LoginManager()
        loginManager.logIn([ .publicProfile, .email], viewController: self) { loginResult in
            switch loginResult {
                case .failed(let error):
                    print(error)
                case .cancelled:
                    print("User cancelled login.")
                case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                    print("Logged in!")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
 
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
