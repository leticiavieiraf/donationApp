//
//  DonatorProfileViewController.swift
//  donationApp
//
//  Created by Letícia Fernandes on 11/03/17.
//  Copyright © 2017 PUC. All rights reserved.

import UIKit
import FirebaseAuth
import FacebookLogin
import FBSDKLoginKit
import FacebookCore
import SVProgressHUD
import Kingfisher

class DonatorProfileViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    // MARK: Life Cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if userLoggedIn() {
            displayUserInformation()
        } else {
            Helper.redirectToLogin()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupTabBar()
    }
    
    // MARK: Check Login method
    func userLoggedIn() -> Bool {
        let donatorUserLoggedIn = Helper.donatorUserLoggedIn()
        var isLogged = true
        
        if !donatorUserLoggedIn {
            isLogged = false
            print("Facebook: User IS NOT logged in!")
            print("Firebase: User IS NOT logged in!")
        }
        return isLogged
    }
    
    // MARK: Setup TabBarController methods
    func setupTabBar() {
        self.tabBarController?.title = "Perfil"
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        self.tabBarController?.navigationItem.leftBarButtonItem = nil
        self.tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: Setup DataSource methods
    func displayUserInformation() {
        self.nameLabel.text = Auth.auth().currentUser?.displayName
        self.emailLabel.text = Auth.auth().currentUser?.email
        loadImageProfile()
    }
    
    func loadImageProfile() {
        let accessToken = FBSDKAccessToken.current().tokenString
        let url = URL(string: "https://graph.facebook.com/me/picture?type=normal&return_ssl_resources=1&access_token="+accessToken!)
        let defaultImage = UIImage(named: "ico-default")
        self.profileImageView.kf.setImage(with: url, placeholder: defaultImage)
    }
    
    // MARK: Logout methods
    func logoutFacebook() {
        let loginManager = LoginManager()
        loginManager.logOut()
    }
    
    func logoutFirebase() {
        let firebaseAuth = Auth.auth()
        do {
            SVProgressHUD.setDefaultStyle(.dark)
            SVProgressHUD.show()
            
            try firebaseAuth.signOut()
            
            SVProgressHUD.dismiss()
            Helper.redirectToLogin()
            
        } catch let signOutError as NSError {
            let errorMsg = "Erro ao realizar logout no Firebase: " + signOutError.localizedDescription
            self.showAlert(title: "Ops...", message: errorMsg, handler: nil)
        }
    }
    
    // MARK: Action
    @IBAction func logout(_ sender: Any) {
        let donatorUserLoggedIn = Helper.donatorUserLoggedIn()
        
        if donatorUserLoggedIn {
            if AccessToken.current != nil {
                logoutFacebook()
            }
            
            if Auth.auth().currentUser != nil {
                logoutFirebase()
            }
        }
    }
}
