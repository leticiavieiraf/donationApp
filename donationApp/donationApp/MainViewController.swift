//
//  MainViewController.swift
//  donationApp
//
//  Created by Letícia Fernandes on 08/03/17.
//  Copyright © 2017 PUC. All rights reserved.
//

import UIKit
import FacebookLogin
import FBSDKLoginKit
import FacebookCore
import FirebaseAuth

class MainViewController: UIViewController, FBSDKLoginButtonDelegate  {

    @IBOutlet weak var loginBtn: FBSDKLoginButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if AccessToken.current != nil && FIRAuth.auth()?.currentUser != nil {
            print("Facebook: User IS logged in!")
            print("Firebase: User IS logged in!")
            
            // Entra como Doador
            let donatorsTabBarC = UIStoryboard(name: "Donators", bundle:nil).instantiateViewController(withIdentifier: "tabBarControllerID") as! UITabBarController
            
            let donatorsTabBarCNav = UINavigationController(rootViewController: donatorsTabBarC)
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = donatorsTabBarCNav

        } else {
            print("Facebook: User IS NOT logged in!")
            print("Firebase: User IS NOT logged in!")
        }

        loginBtn.delegate = self
        loginBtn.readPermissions = ["public_profile", "email"]
     }
    
    // Login Facebook
    public func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        //Error
        if(error != nil)
        {
            print("Facebook: Login Error!")
            // Show alert
            let errorMsg = "Erro ao realizar login no Facebook: " + error.localizedDescription
            let alert = UIAlertController(title: "Erro",
                                          message: errorMsg,
                                          preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "Ok",
                                         style: .default)
            
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)

            return
        }
        
        //Canceled
        if (result.isCancelled) {
            print("Facebook: User cancelled login.")
            
            // Show alert
            let errorMsg = "O login foi cancelado pelo usuário."
            let alert = UIAlertController(title: "Atenção",
                                          message: errorMsg,
                                          preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "Ok",
                                         style: .default)
            
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        //Success
        if let userToken = result.token
        {
            print("Facebook: User Logged in Successfully!")
            
            // Login no Firebase!
            let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
            FIRAuth.auth()?.signIn(with: credential) { (user, error) in
                
                if let error = error {
                    print("Firebase: Login Error!")
                    
                    // Show alert
                    let errorMsg = "Erro ao realizar login no Firebase: " + error.localizedDescription
                    let alert = UIAlertController(title: "Erro",
                                                  message: errorMsg,
                                                  preferredStyle: .alert)
                    
                    let okAction = UIAlertAction(title: "Ok",
                                                 style: .default)
                    
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)

                    return
                }
                
                if let user = user {
                    print("Firebase: Login successfull")
                    
                    // Entra como Doador
                    let donatorsTabBarC = UIStoryboard(name: "Donators", bundle:nil).instantiateViewController(withIdentifier: "tabBarControllerID") as! UITabBarController
                    
                    let donatorsTabBarCNav = UINavigationController(rootViewController: donatorsTabBarC)
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.window?.rootViewController = donatorsTabBarCNav
                }
            }
        }
    }
    
    public func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
        //Nao vai entrar aqui!
        print("Facebook: User Logged out Successfully!")
        
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
        } catch let signOutError as NSError {
            print ("Firebase: Error signing out: %@", signOutError)
        }
    }
}
        











        
        
        // Login Button
//        let loginButton = UIButton(type: .custom)
//        loginButton.backgroundColor = UIColor.darkGray
//        loginButton.frame = CGRect(origin: CGPoint(x:0, y:0), size: CGSize(width: 180, height: 40))
//        loginButton.center = view.center;
//        loginButton.setTitle("Log in with Facebook", for: .normal)
//
//        loginButton.addTarget(self, action:#selector(loginButtonClicked), for: .touchUpInside)
//        
//        view.addSubview(loginButton)
        
        
        //Logout Button
//        let logoutButton = UIButton(type: .custom)
//        logoutButton.backgroundColor = UIColor.darkGray
//        logoutButton.frame = CGRect(origin: CGPoint(x:0, y:0), size: CGSize(width: 180, height: 40))
//        logoutButton.center = view.center;
//        logoutButton.setTitle("Log out", for: .normal)
//        
//      
//        logoutButton.addTarget(self, action:#selector(loginButtonClicked), for: .touchUpInside)
        
//        view.addSubview(logoutButton)
    
    
    
    
    
    
    
//    
//    @objc func loginButtonClicked() {
//        let loginManager = LoginManager()
//        loginManager.logIn([ .publicProfile, .email], viewController: self) {
//            
//            loginResult in
//            switch loginResult {
//                case .failed(let error):
//                    print(error)
//                case .cancelled:
//                    print("User cancelled login.")
//                case .success(let grantedPermissions, let declinedPermissions, let accessToken):
//                    print("Logged in!")
//                    
//            }
//        }
//    }
//    
//    @objc func logoutButtonClicked() {
//        let loginManager = LoginManager()
//        loginManager.logOut()
//    }
