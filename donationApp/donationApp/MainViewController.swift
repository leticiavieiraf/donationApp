//
//  MainViewController.swift
//  donationApp
//
//  Created by Natalia Sheila Cardoso de Siqueira on 08/03/17.
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
        
        if (AccessToken.current == nil) {
            print("User IS NOT logged in!")
            //AccessToken.refreshCurrentToken()
        } else {
            print("User IS logged in!")
        }
        
        
        if FIRAuth.auth()?.currentUser != nil {
            // User is signed in.
            // ...
        } else {
            // No user is signed in.
            // ...
        }
        
        loginBtn.delegate = self
        loginBtn.readPermissions = ["public_profile", "email"]
        
     }
    
    
    public func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        //Error
        if(error != nil)
        {
            print("Error!!!!! FACEBOOK LOGIN")
            print(error.localizedDescription)
            return
        }
        
        //Canceled
        if (result.isCancelled) {
            print("User cancelled login.")
            return
        }
        
        //Success
        if let userToken = result.token
        {
            //Get user access token
            
            print("User Logged in Successfully!")
            print(userToken.tokenString)
            print(userToken.userID)
            print(result.grantedPermissions)
            print(userToken.declinedPermissions)
            
            let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
            
            FIRAuth.auth()?.signIn(with: credential) { (user, error) in
                
                if let error = error {
                    print("Error!!!!! FIREBASE LOGIN")
                    return
                }
                
                if let user = user {
                    print("Login successfull firebase!!!")
                    print(user.email)
                }
            }
            
            let user = FIRAuth.auth()?.currentUser
            
            //            let protectedPage = self.storyboard?.instantiateViewControllerWithIdentifier("ProtectedPageViewController") as! ProtectedPageViewController
            //            let protectedPageNav = UINavigationController(rootViewController: protectedPage)
            //            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            //            appDelegate.window?.rootViewController = protectedPageNav
            
        }
    }
    
    public func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
        print("User Logged out Successfully!")
        
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
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
