//
//  LoginInstitutionViewController.swift
//  donationApp
//
//  Created by Leticia Vieira Fernandes on 14/04/17.
//  Copyright © 2017 PUC. All rights reserved.

import UIKit
import Firebase
import SVProgressHUD
import CryptoSwift
import Locksmith

class LoginInstitutionViewController: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var emailErrorImage: UIImageView!
    @IBOutlet weak var passwordErrorImage: UIImageView!
    
    let ref = Database.database().reference(withPath: "features")

    // MARK: - Life Cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Actions
    @IBAction func logIn(_ sender: Any) {
        
        if isEmptyFields() {
            return
        }
        else {
            loginWithFirebase()
        }
    }
    
    // MARK: - Firebase methods
    func loginWithFirebase() {
        
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.show()

        // Criptografia segura e ideal Hash SHA-256 (PBKDF2)
        let salt = loadSalt()
        let saltAndPassword = salt + self.passwordField.text!
        let password_sha256 = sha256SaltHash(saltAndPassword, salt: salt)
        
        Auth.auth().signIn(withEmail: self.emailField.text!, password: password_sha256) { (user, error) in
            
            SVProgressHUD.dismiss()
            
            //Error
            if let error = error {
                print("Firebase: Login Error!")
                Helper.showAlert(title: "Erro", message: "Erro ao realizar login: " + error.localizedDescription, viewController: self)
                return
            }
            
            //Success
            if user != nil {
                print("Firebase: Login successfull")
                self.redirectToInstitutionsStoryboard()
            }
        }
    }
    
    // MARK: - Encryption methods
    func sha256SaltHash(_ password: String, salt: String) -> String {
        
        let bytesPass: Array<UInt8> = Array(password.utf8);
        let byteSalt: Array<UInt8> = Array(salt.utf8)
        
        do {
            let hashed = try PKCS5.PBKDF2(password: bytesPass, salt: byteSalt, iterations: 4096, variant: .sha256).calculate()
            let hashedStr = Data(bytes: hashed).toHexString()
            
            return hashedStr
            
        } catch {
            print (error)
        }
        
        return password
    }
    
    // MARK: - Keychain Access method
    func loadSalt() -> String {
        return Constants.kGeneral
        
//        // Reading data from the keychain
//        if let saltDictionary = Locksmith.loadDataForUserAccount(userAccount: self.emailField.text!) {
//            if let userSalt = saltDictionary["userSalt"] {
//              return userSalt as! String
//            }
//        }
//        
//         return ""
    }
    
    // MARK: - Redirect methods
    func redirectToInstitutionsStoryboard() {
        let institutionsTabBarController = UIStoryboard(name: "Institutions", bundle:nil).instantiateViewController(withIdentifier: "tabBarControllerID") as! UITabBarController
        let institutionsNavigationController = UINavigationController(rootViewController: institutionsTabBarController)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = institutionsNavigationController
    }
    
    // MARK: - Validation methods
    func isEmptyFields() -> Bool {
        
        var isEmpty: Bool = false;
        
        if let email = self.emailField.text, email.isEmpty {
            self.emailErrorImage.isHidden = false;
            isEmpty = true;
        } else {
            self.emailErrorImage.isHidden = true;
        }
        
        if let password = self.passwordField.text, password.isEmpty {
            self.passwordErrorImage.isHidden = false;
            isEmpty = true;
        } else {
            self.passwordErrorImage.isHidden = true;
        }
        
        return isEmpty
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
