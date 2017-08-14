//
//  Institution.swift
//  donationApp
//
//  Created by Letícia Fernandes on 10/03/17.
//  Copyright © 2017 PUC. All rights reserved.
//

import Foundation
import Firebase
import MapKit

class Institution : NSObject, MKAnnotation {
    
    var key: String
    var name: String
    var info: String
    var email: String
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
    var coordinate: CLLocationCoordinate2D
    var ref: DatabaseReference?
    
    override init() {
        
        self.key = ""
        self.name = ""
        self.info = ""
        self.email = ""
        self.contact = ""
        self.phone = ""
        self.bank = ""
        self.agency = ""
        self.accountNumber = ""
        self.address = ""
        self.district = ""
        self.city = ""
        self.state = ""
        self.zipCode = ""
        self.group = ""
        self.coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        self.ref = nil
        
        super.init()
    }
    
    init(name: String, info: String, email: String, contact: String, phone: String,
         bank: String, agency: String, accountNumber: String, address: String, district: String,
         city: String, state: String, zipCode: String, group: String, coordinate: CLLocationCoordinate2D, key: String = "") {
        
        self.key = key
        self.name = name
        self.info = info
        self.email = email
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
        self.coordinate = coordinate
        self.ref = nil
        
         super.init()
    }
    
    var title: String? {
        return name
    }
    
    var subtitle: String? {
        return group
    }
    
    init(snapshot: DataSnapshot) {
        key = snapshot.key
        if !(snapshot.value is NSNull) {
            let snapshotValue = snapshot.value as! [String: AnyObject]
            name = snapshotValue["Name"] as! String
            info = snapshotValue["description"] as! String
            email = snapshotValue["e_mail"] as! String
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
            coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
            ref = snapshot.ref
        } else {
            name = "Erro"
            info = "Erro"
            email = "Erro"
            contact = "Erro"
            phone = "Erro"
            bank = "Erro"
            agency = "Erro"
            accountNumber = "Erro"
            address = "Erro"
            district = "Erro"
            city = "Erro"
            state = "Erro"
            zipCode = "Erro"
            group = "Erro"
            coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
            ref = nil
        }
    }
    
    
    func toAnyObject() -> Any {
        return [
            "Name": name,
            "description": info,
            "e_mail": email,
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
            "IDSetor": group,
            
        ]
    }
}
