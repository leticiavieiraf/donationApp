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

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if AccessToken.current != nil || FIRAuth.auth()?.currentUser != nil {
            
            self.nameLabel.text = FIRAuth.auth()?.currentUser?.displayName
            self.emailLabel.text = FIRAuth.auth()?.currentUser?.email
            self.load_image(urlString: (FIRAuth.auth()?.currentUser?.photoURL?.absoluteString)!)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.title = "Perfil"
    }
    
    func load_image(urlString:String)
    {
        let url: URL = URL(string: urlString)!
        
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: url) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            DispatchQueue.main.async {
                self.profileImageView.image = UIImage(data: data!)
            }
        }
    }
    
    @IBAction func logout(_ sender: Any) {
        
        // Logout Facebook
        if AccessToken.current != nil {
            let loginManager = LoginManager()
            loginManager.logOut()
        }
       
        // Logout Firebase
        if FIRAuth.auth()?.currentUser != nil {
            
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
