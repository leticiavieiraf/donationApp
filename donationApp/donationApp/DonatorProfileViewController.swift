//
//  DonatorProfileViewController.swift
//  donationApp
//
//  Created by Letícia Fernandes on 11/03/17.
//  Copyright © 2017 PUC. All rights reserved.

import UIKit
import FirebaseAuth
import FacebookLogin
import FacebookCore
import SVProgressHUD
import Kingfisher

class DonatorProfileViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if AccessToken.current != nil || Auth.auth().currentUser != nil {
            
            self.nameLabel.text = Auth.auth().currentUser?.displayName
            self.emailLabel.text = Auth.auth().currentUser?.email
            
            // Load image profile
            let url: URL = URL(string: (Auth.auth().currentUser?.photoURL?.absoluteString)!)!
            let defaultImage = UIImage(named: "ico-default")
            self.profileImageView.kf.setImage(with: url, placeholder: defaultImage);
            
//            do {
////                try self.loadProfileImageWith(urlString: (Auth.auth().currentUser?.photoURL?.absoluteString)!)
//                
//            } catch let loadingImageError as NSError {
//                
//                SVProgressHUD.dismiss()
//                print(loadingImageError.localizedDescription)
//                self.profileImageView.image = UIImage(named: "user-big")
//            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.title = "Perfil"
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
    }
    
//    func loadProfileImageWith(urlString:String) throws
//    {
//        let url: URL = URL(string: urlString)!
//    
//        SVProgressHUD.setDefaultStyle(.dark)
//        SVProgressHUD.show()
//        
//        DispatchQueue.global().async {
//            let data = try? Data(contentsOf: url)
//            
//            DispatchQueue.main.async {
//                SVProgressHUD.dismiss()
//                if let data = data {
//                    self.profileImageView.image = UIImage(data: data!);
//                }
//                
//            }
//        }
//    }
    
    @IBAction func logout(_ sender: Any) {
        
        // Logout Facebook
        if AccessToken.current != nil {
            let loginManager = LoginManager()
            loginManager.logOut()
        }
       
        // Logout Firebase
        if Auth.auth().currentUser != nil {
            
            let firebaseAuth = Auth.auth()
            do {
                
                SVProgressHUD.setDefaultStyle(.dark)
                SVProgressHUD.show()
                
                try firebaseAuth.signOut()
                
                SVProgressHUD.dismiss()
                
                // Redireciona para tela de login
                let loginNav = UIStoryboard(name: "Main", bundle:nil).instantiateInitialViewController()
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = loginNav
                
            } catch let signOutError as NSError {
        
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
