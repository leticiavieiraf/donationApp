//
//  InstitutionProfileViewController.swift
//  donationApp
//
//  Created by Letícia Fernandes on 14/04/17.
//  Copyright © 2017 PUC. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import SVProgressHUD

class InstitutionProfileViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    
    var institutionUser : InstitutionUser!
    let refInstitutionUsers = Database.database().reference(withPath: "institution-users")
    
    // MARK: - Lyfe Cycle methods
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
    
    // MARK: - Check Login methods
    func userLoggedIn() -> Bool {
        let institutionUserLoggedIn = Helper.institutionUserLoggedIn()
        var isLogged = true
        
        if !institutionUserLoggedIn {
            isLogged = false
            print("Firebase: User IS NOT logged in!")
        }
        return isLogged
    }
    
    // MARK: - Setup TabBarController methods
    func setupTabBar() {
        self.tabBarController?.title = "Perfil"
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        self.tabBarController?.navigationItem.leftBarButtonItem = nil
        self.tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - Firebase methods
    func getInstitutionUser(onSuccess: @escaping (_ user: InstitutionUser) -> ()) {
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.show()
        
        let userUID = Auth.auth().currentUser!.uid
        refInstitutionUsers.child(userUID.lowercased()).observeSingleEvent(of: .value, with: { (snapshot) in
            SVProgressHUD.dismiss()
            
            let user = InstitutionUser(snapshot: snapshot)
            onSuccess(user)
        })
    }
    
    // MARK: - Setup DataSource methods
    func displayUserInformation() {
        
        getInstitutionUser { (user) in
            self.institutionUser = user
            
            self.nameLabel.text = self.institutionUser.name != "" ? self.institutionUser.name : "-"
            self.emailLabel.text = self.institutionUser.email != "" ? self.institutionUser.email : "-"
            self.addressLabel.text = Helper.institutionUserAddress(self.institutionUser)
            self.infoLabel.text = self.institutionUser.group != "" ? self.institutionUser.group : "-"
            self.phoneLabel.text = self.institutionUser.phone != "" ? self.institutionUser.phone : "-"
        }
    }
    
    // MARK: - Logout methods
    func logoutFirebase() {
        let firebaseAuth = Auth.auth()
        do {
            SVProgressHUD.setDefaultStyle(.dark)
            SVProgressHUD.show()
            
            try firebaseAuth.signOut()
            
            SVProgressHUD.dismiss()
            Helper.redirectToLogin()
            
        } catch let signOutError as NSError {
            let errorMsg = "Erro ao realizar logout: " + signOutError.localizedDescription
            self.showAlert(title: "Ops...", message: errorMsg, handler: nil)
        }
    }
    
    // MARK: Action
    @IBAction func logout(_ sender: Any) {
        let institutionUserLoggedIn = Helper.institutionUserLoggedIn()
        
        if institutionUserLoggedIn {
            logoutFirebase()
        }
    }
}
