//
//  RegisterInstitutionViewController.swift
//  donationApp
//
//  Created by Leticia Vieira Fernandes on 14/04/17.
//  Copyright © 2017 PUC. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import SVProgressHUD
import CryptoSwift
import Locksmith

class RegisterInstitutionViewController: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!

    @IBOutlet weak var emailErrorImage: UIImageView!
    @IBOutlet weak var passwordErrorImage: UIImageView!
    @IBOutlet weak var confirmPaswordErrorImage: UIImageView!
    
    let refInstitutions = Database.database().reference(withPath: "features")
    let refInstitutionsUsers = Database.database().reference(withPath: "institution-users")
    
    var password_sha256 : String = "";
    var salt : String = "";

    // MARK: Life Cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
    }
    
    // MARK: Actions
    @IBAction func registerAction(_ sender: Any) {
        if isEmptyFields() {
            return
        }
        if !isMatchPasswords() {
            self.showAlert(title: "Atenção!", message: "As senhas digitadas não correspondem.", handler: nil)
            return
        }
        if isShortPassword() {
            self.showAlert(title: "Atenção!", message: "A senha deve ter no mínimo 6 caracteres.", handler: nil)
            return
        }
        else {
            self.validateAndRegister()
        }
    }
    
    @IBAction func closePopOver(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Firebase methods
    func register(_ institution : Institution) {
        
        // Criptografia segura e ideal Hash SHA-256 (PBKDF2)
        salt = Constants.kGeneral
        let saltAndPassword = salt + self.passwordField.text!
        password_sha256 = sha256SaltHash(saltAndPassword, salt: salt)
        
        Auth.auth().createUser(withEmail: self.emailField.text!, password: password_sha256) { (authResult, error) in
            
            var title = ""
            var msg = ""
            
            //Error
            if let error = error {
                SVProgressHUD.dismiss()
                print("Firebase: Register Error!")
                title = "Erro"
                msg = error.localizedDescription
            }
            
            //Success
            if let authResult = authResult {
                print("Firebase: Register successfull")
                title = ""
                msg = "Cadastro realizado com sucesso!"
                
                // Insere usuário no banco de dados do Firebase
                self.insertRegisteredUser(institution, uid: authResult.user.uid)
            }
            
            self.showAlert(title: title, message: msg, handler: { () in
                              if (error == nil) {
                                self.dismiss(animated: true, completion: nil)
                              }
                           })
        }
    }
    
    func getInstitutions(onSuccess: @escaping (_ institutions: [Institution]) -> (),
                         onFailure: @escaping (_ error: Error) -> ()) {
        
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.show()
        
        refInstitutions.observe(.value, with: { snapshot in
            var institutions = [Institution()]
            
             for item in snapshot.children {
                let institution = Institution(snapshot: item as! DataSnapshot)
                institutions.append(institution)
                
            }
            SVProgressHUD.dismiss()
            
            onSuccess(institutions)
        })
    }
    
    //Save registered user in database
    func insertRegisteredUser(_ institution: Institution, uid: String) {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
        let dateStr = formatter.string(from: date)
    
        let userInstitution = InstitutionUser(uid: uid.lowercased(),
                                          name: institution.name,
                                          info: institution.info,
                                          email: institution.email,
                                          password: password_sha256,
                                          registerDate: dateStr,
                                          contact: institution.contact,
                                          phone: institution.phone,
                                          bank: institution.bank,
                                          agency: institution.agency,
                                          accountNumber: institution.accountNumber,
                                          address: institution.address,
                                          district: institution.district,
                                          city: institution.city,
                                          state: institution.state,
                                          zipCode: institution.zipCode,
                                          group: institution.group)
        
        let userInstitutionRef = self.refInstitutionsUsers.child(userInstitution.uid)
        userInstitutionRef.setValue(userInstitution.toAnyObject())
        
        SVProgressHUD.dismiss()
    }
    
    //MARK: Validation methods {
    func isEmptyFields() -> Bool {
        var isEmpty : Bool = false;
        
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
        
        if let confirmPassword = self.confirmPasswordField.text, confirmPassword.isEmpty {
            self.confirmPaswordErrorImage.isHidden = false;
            isEmpty = true;
        } else {
            self.confirmPaswordErrorImage.isHidden = true;
        }
        
        return isEmpty
    }
    
    func isMatchPasswords() -> Bool {
        var  isMatch : Bool = true;
        
        if self.passwordField.text != self.confirmPasswordField.text {
            isMatch = false
        }
        
        return isMatch
    }
    
    func isShortPassword() -> Bool {
        var  isShortPassword : Bool = false;
        
        if (self.passwordField.text?.characters.count)! < 6 {
            isShortPassword = true
        }
        
        return isShortPassword
    }
    
    func validateAndRegister() {
        self.getInstitutions(onSuccess: { (institutions) in
            
            if let validInstitution = self.findInstitutionInResults(institutions) {
                self.register(validInstitution)
            }
            else {
                SVProgressHUD.dismiss()
                self.showAlert(title: "Atenção!", message: "\n Não foi possível realizar o cadastro.\n\n Este e-mail não foi encontrado na base de Instituições reconhecidas.", handler: nil)
            }
        }, onFailure: { (error) in
            self.showAlert(title: "Ops...", message: "Não foi possível validar o e-mail. Tente novamente mais tarde.", handler: nil)
        })
    }
    
    func findInstitutionInResults(_ institutions : [Institution]) -> Institution? {
        
        var foundInstitution : Institution? = nil
        
        for institution in institutions {
            if self.emailField.text == institution.email  {
                foundInstitution = institution
            }
        }
        return foundInstitution
    }
    
    // MARK: Encryption method
    func sha256SaltHash(_ saltAndPassword: String, salt: String) -> String {
        
        let byteSaltAndPass: Array<UInt8> = Array(saltAndPassword.utf8);
        let byteSalt: Array<UInt8> = Array(salt.utf8)
        
        do {
            // Gera o hash a partir dos bytes do (salt + senha) e dos bytes do (salt).
            let hash = try PKCS5.PBKDF2(password: byteSaltAndPass, salt: byteSalt, iterations: 4096, variant: .sha256).calculate()
            // Converte o hash em bytes para string
            let hashStr = Data(bytes: hash).toHexString()
            
            // Retorna o hash
            return hashStr
            
        } catch {
            print(error)
        }
        
        return saltAndPassword
    }
    
    // MARK: Keychain Access method
//    func saveSalt() {
//        do {
//            // Writing data to the keychain
//            try Locksmith.saveData(data: ["userSalt": self.salt], forUserAccount: self.emailField.text!)
//            
//            // Saving data in UserDefaults
//            let preferences = UserDefaults.standard
//            preferences.setValue(self.salt, forKey: "userSalt")
//            preferences.synchronize()
//          
//        } catch {
//            print(error)
//        }
//    }
    
    // MARK: Private methods
    func randomString() -> String {
        
        let length: Int = randomNumber()
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
    
    func randomNumber() -> Int {
        let max : UInt32 = 20
        let min : UInt32 = 10
        
        let random_number = Int(arc4random_uniform(max) + min)
        return random_number
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
