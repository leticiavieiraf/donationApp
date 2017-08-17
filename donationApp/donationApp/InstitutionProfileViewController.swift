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
        
        if Auth.auth().currentUser != nil {
            
            let userUID = Auth.auth().currentUser!.uid

            SVProgressHUD.setDefaultStyle(.dark)
            SVProgressHUD.show()
            
            refInstitutionUsers.child(userUID.lowercased()).observeSingleEvent(of: .value, with: { (snapshot) in
                self.institutionUser = InstitutionUser(snapshot: snapshot)
                
                self.nameLabel.text = self.institutionUser.name != "" ? self.institutionUser.name : "-"
                self.emailLabel.text = self.institutionUser.email != "" ? self.institutionUser.email : "-"
                self.addressLabel.text = Helper.institutionUserAddress(self.institutionUser)
                self.infoLabel.text = self.institutionUser.group != "" ? self.institutionUser.group : "-"
                self.phoneLabel.text = self.institutionUser.phone != "" ? self.institutionUser.phone : "-"
                
                SVProgressHUD.dismiss()
            })
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.title = "Perfil"
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
    }
    
    // MARK: - Firebase method
    @IBAction func logout(_ sender: Any) {
        
        if Auth.auth().currentUser != nil {
            
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
                
                // Redireciona para tela de login
                let loginNav = UIStoryboard(name: "Main", bundle:nil).instantiateInitialViewController()
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = loginNav
                
            } catch let signOutError as NSError {
                
                // Show alert
                let errorMsg = "Erro ao realizar logout: " + signOutError.localizedDescription
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
