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

class MainViewController: UIViewController, FBSDKLoginButtonDelegate  {

    @IBOutlet weak var loginBtn: FBSDKLoginButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Auth.auth().currentUser != nil {
            
            if AccessToken.current != nil {
                
                // Entra como Doador
                let donatorsTabBarC = UIStoryboard(name: "Donators", bundle:nil).instantiateViewController(withIdentifier: "tabBarControllerID") as! UITabBarController
                
                let donatorsTabBarCNav = UINavigationController(rootViewController: donatorsTabBarC)
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = donatorsTabBarCNav
                
            } else {
                
                // Entra como Instituição
                let institutionsTabBarController = UIStoryboard(name: "Institutions", bundle:nil).instantiateViewController(withIdentifier: "tabBarControllerID") as! UITabBarController
                let institutionsNavigationController = UINavigationController(rootViewController: institutionsTabBarController)
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = institutionsNavigationController
            }
        }
        
        loginBtn.delegate = self
        loginBtn.readPermissions = ["public_profile", "email"]
        loginBtn.setTitle("Entrar com Facebook", for: .normal)
        loginBtn.layer.cornerRadius = 4.0
     }
    
    // Login com Facebook
    public func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        //Error
        if(error != nil)
        {
            print("Facebook: Login Error!")
            self.showAlert(withTitle: "Erro", message: "Erro ao realizar login no Facebook: " + error.localizedDescription)
            return
        }
        
        //Canceled
        if (result.isCancelled) {
            print("Facebook: User cancelled login.")
            self.showAlert(withTitle: "Atenção", message: "O login foi cancelado.")
            return
        }
        
        //Success
        if let userToken = result.token
        {
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
                self.showAlert(withTitle: "Erro", message: "Erro ao realizar login no Firebase: " + error.localizedDescription)
                return
            }
            
            //Success
            if let user = user {
                print("Firebase: Login successfull")
                
                // Redireciona para o storyboard de Doador
                let donatorsTabBarController = UIStoryboard(name: "Donators", bundle:nil).instantiateViewController(withIdentifier: "tabBarControllerID") as! UITabBarController
                let donatorsNavigationController = UINavigationController(rootViewController: donatorsTabBarController)
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = donatorsNavigationController
            }
        }
    }
    
    public func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
        //Não vai entrar aqui!
        print("Facebook: User Logged out Successfully!")
        
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Firebase: Error signing out: %@", signOutError)
        }
    }
    
    func showAlert(withTitle: String, message: String) {
        
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok",
                                     style: .default)
        
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
}
