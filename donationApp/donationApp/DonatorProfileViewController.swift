//
//  DonatorProfileViewController.swift
//  donationApp
//
//  Created by Natalia Sheila Cardoso de Siqueira on 11/03/17.
//  Copyright © 2017 PUC. All rights reserved.
//

import UIKit
import FirebaseAuth
import FacebookLogin
import FacebookCore

class DonatorProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.title = "Perfil"
    }

    @IBAction func logout(_ sender: Any) {
        
        // Logout Facebook
        if AccessToken.current != nil {
            let loginManager = LoginManager()
            loginManager.logOut()
        }
       
        // Logout Firebase
        if FIRAuth.auth()?.currentUser == nil {
            
            let firebaseAuth = FIRAuth.auth()
            do {
                try firebaseAuth?.signOut()
                
                // Redireciona para tela de login
                let loginNav = UIStoryboard(name: "Main", bundle:nil).instantiateInitialViewController()
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = loginNav
                
            } catch let signOutError as NSError {
                //print ("Error signing out: %@", signOutError)
                
                // Show alert
                let errorMsg = "Erro ao realizar logout no Firebase: " + signOutError.localizedDescription
                let alert = UIAlertController(title: "Erro",
                                              message: errorMsg,
                                              preferredStyle: .alert)
            
                let okAction = UIAlertAction(title: "Ok",
                                            style: .default)
                
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
  

}
