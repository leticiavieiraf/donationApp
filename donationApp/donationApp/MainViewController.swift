//
//  MainViewController.swift
//  donationApp
//
//  Created by Letícia Fernandes on 08/03/17.
//  Copyright © 2017 PUC. All rights reserved.

import UIKit
import FacebookLogin
import FBSDKLoginKit
import FacebookCore
import FirebaseAuth
import SVProgressHUD
import SafariServices

class MainViewController: UIViewController, FBSDKLoginButtonDelegate, SFSafariViewControllerDelegate  {

    @IBOutlet weak var loginBtn: FBSDKLoginButton!
    
    // MARK: - Life Cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (Auth.auth().currentUser != nil && AccessToken.current != nil) {
            redirectToDonatorsStoryboard()
        } else if Auth.auth().currentUser != nil {
            redirectToInstitutionsStoryboard()
        }
        
        loginBtn.delegate = self
        loginBtn.readPermissions = ["public_profile", "email"]
        loginBtn.setTitle("Entrar com Facebook", for: .normal)
        loginBtn.layer.cornerRadius = 4.0
     }
    
    // MARK: - Login methods
    
    // Login com Facebook
    public func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        //Error
        if(error != nil) {
            print("Facebook: Login Error!")
            Helper.showAlert(title: "Erro", message: "Erro ao realizar login no Facebook: " + error.localizedDescription, viewController: self)
            return
        }
        
        //Canceled
        if (result.isCancelled) {
            print("Facebook: User cancelled login.")
            Helper.showAlert(title: "Ops...", message: "O login foi cancelado.", viewController: self)
            return
        }
        
        //Success
        if (result.token != nil) {
            print("Facebook: User Logged in Successfully!")
            logInWithFirebase()
        }
    }
    
    // Login no Firebase com o Token do Facebook
    func logInWithFirebase() {
        
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.show()
        
        let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        Auth.auth().signIn(with: credential) { (user, error) in
            
            SVProgressHUD.dismiss()
            
            //Error
            if let error = error {
                print("Firebase: Login Error!")
                Helper.showAlert(title: "Erro", message: "Erro ao realizar login no Firebase: " + error.localizedDescription, viewController: self)
                return
            }
            
            //Success
            if user != nil {
                print("Firebase: Login successfull")
                self.redirectToDonatorsStoryboard()
            }
        }
    }
    
    // MARK: - LogOut methods
    func logOutFromFacebook() {
        if AccessToken.current != nil {
            let loginManager = LoginManager()
            loginManager.logOut()
        }
    }
    
    public func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Facebook: User Logged out Successfully!")
    }
    
    // MARK: - Redirect methods
    func redirectToDonatorsStoryboard() {
        let donatorsTabBarController = UIStoryboard(name: "Donators", bundle:nil).instantiateViewController(withIdentifier: "tabBarControllerID") as! UITabBarController
        
        let donatorsNavigationController = UINavigationController(rootViewController: donatorsTabBarController)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = donatorsNavigationController
    }
    
    func redirectToInstitutionsStoryboard() {
        let institutionsTabBarController = UIStoryboard(name: "Institutions", bundle:nil).instantiateViewController(withIdentifier: "tabBarControllerID") as! UITabBarController
        
        let institutionsNavigationController = UINavigationController(rootViewController: institutionsTabBarController)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = institutionsNavigationController
    }
    
    // MARK: - SFSafariViewControllerDelegate
    func safariViewController(_ controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
        
        controller.dismiss(animated: true, completion: nil)
        if (!didLoadSuccessfully) {
            Helper.showAlert(title: "Ops...", message: "Não foi possível completar a operação, tente novamente.", viewController: self)
        }
    }
}
