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

    // MARK: Life Cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setupNavBar()
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: Setup NavigationBar methods
    func setupNavBar() {
        let arrowImage = UIImage(named: "arrow-back")
        let button = UIButton(type: .system)
        button.setImage(arrowImage, for: .normal)
        button.addTarget(self, action: #selector(goBack), for: UIControlEvents.touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: (arrowImage?.size.width)!, height: (arrowImage?.size.height)!)
        let barButton = UIBarButtonItem(customView: button)
        
        self.navigationItem.leftBarButtonItem = barButton
        self.navigationItem.rightBarButtonItem = nil
    }
    
    func goBack() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: Redirect methods
    func redirectToInstitutionsStoryboard() {
        let institutionsTabBarController = UIStoryboard(name: "Institutions", bundle:nil).instantiateViewController(withIdentifier: "tabBarControllerID") as! UITabBarController
        
        let institutionsNavigationController = UINavigationController(rootViewController: institutionsTabBarController)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = institutionsNavigationController
    }
    
    // MARK: Actions
    @IBAction func logIn(_ sender: Any) {
        if isEmptyFields() {
            return
        }
        else {
            loginWithFirebase()
        }
    }
    
    // MARK: Firebase methods
    func loginWithFirebase() {
        
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.show()

        // Criptografia Hash SHA-256 (PBKDF2)
        let salt = Constants.kGeneral
        let saltAndPassword = salt + self.passwordField.text!
        let password_sha256 = sha256SaltHash(saltAndPassword, salt: salt)
        
        Auth.auth().signIn(withEmail: self.emailField.text!, password: password_sha256) { (user, error) in
            
            SVProgressHUD.dismiss()
            
            //Error
            if let error = error {
                print("Firebase: Login Error!")
                self.showAlert(title: "Ops...", message: "Erro ao realizar login: " + error.localizedDescription, handler: nil)
                return
            }
            
            //Success
            if user != nil {
                print("Firebase: Login successfull")
                self.redirectToInstitutionsStoryboard()
            }
        }
    }
    
    // MARK: Encryption methods
    func sha256SaltHash(_ saltAndPassword: String, salt: String) -> String {
        
        let byteSaltAndPass: Array<UInt8> = Array(saltAndPassword.utf8);
        let byteSalt: Array<UInt8> = Array(salt.utf8)
        
        do {
            let hash = try PKCS5.PBKDF2(password: byteSaltAndPass, salt: byteSalt, iterations: 4096, variant: .sha256).calculate()
            let hashStr = Data(bytes: hash).toHexString()
            
            return hashStr
            
        } catch {
            print(error)
        }
        
        return saltAndPassword
    }
    
    // MARK: Keychain Access method
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
    
    // MARK: Validation methods
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
