//
//  InstitutionUser.swift
//  donationApp
//
//  Created by Letícia Fernandes on 11/03/17.
//  Copyright © 2017 PUC. All rights reserved.
//

import Foundation
import Firebase
import MapKit

class InstitutionUser : NSObject {
    
    var key: String
    let uid: String
    var name: String
    var info: String
    var email: String
    var password: String
    var registerDate: String
    var contact: String
    var phone: String
    var bank: String
    var agency: String
    var accountNumber: String
    var address: String
    var district: String
    var city: String
    var state: String
    var zipCode: String
    var group: String
    var ref: FIRDatabaseReference?
    
    init(uid: String, name: String, info: String, email: String, password: String, registerDate: String, contact: String, phone: String, bank: String, agency: String, accountNumber: String, address: String, district: String, city: String, state: String, zipCode: String, group: String, key: String = "") {
    
        self.key = key
        self.uid = uid
        self.name = name
        self.info = info
        self.email = email
        self.password = password
        self.registerDate = registerDate
        self.contact = contact
        self.phone = phone
        self.bank = bank
        self.agency = agency
        self.accountNumber = accountNumber
        self.address = address
        self.district = district
        self.city = city
        self.state = state
        self.zipCode = zipCode
        self.group = group
        self.ref = nil
    
        super.init()
    }
    
    init(snapshot: FIRDataSnapshot) {
        key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        uid = snapshotValue["uid"] as! String
        name = snapshotValue["Name"] as! String
        info = snapshotValue["description"] as! String
        email = snapshotValue["e_mail"] as! String
        password = snapshotValue["password"] as! String
        registerDate = snapshotValue["registerDate"] as! String
        contact = snapshotValue["contato"] as! String
        phone = snapshotValue["telefone"] as! String
        bank = snapshotValue["banco"] as! String
        agency = snapshotValue["agencia"] as! String
        accountNumber = snapshotValue["conta"] as! String
        address = snapshotValue["endereco"] as! String
        district = snapshotValue["bairro"] as! String
        city = snapshotValue["cidade"] as! String
        state = snapshotValue["estado"] as! String
        zipCode = snapshotValue["cep"] as! String
        group = snapshotValue["IDSetor"] as! String
        ref = snapshot.ref
    }
    
    var title: String? {
    return name
    }
    
    var subtitle: String? {
    return group
    }
    
    func toAnyObject() -> Any {
        return [
        "uid": uid,
        "Name": name,
        "description": info,
        "e_mail": email,
        "password": password,
        "registerDate": registerDate,
        "contato": contact,
        "telefone": phone,
        "banco": bank,
        "agencia": agency,
        "conta": accountNumber,
        "endereco": address,
        "bairro": district,
        "cidade": city,
        "estado": state,
        "cep": zipCode,
        "IDSetor": group
        ]
    }

}
