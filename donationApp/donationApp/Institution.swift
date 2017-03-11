//
//  Institution.swift
//  donationApp
//
//  Created by Letícia Fernandes on 10/03/17.
//  Copyright © 2017 PUC. All rights reserved.
//

import Foundation
import ObjectMapper

struct Institution : Mappable {
    
    var name: String!
    var description: String!
    var email: String!
    var contact: String!
    var phone: String!
    var bank: String!
    var agency: String!
    var accountNumber: String!
    var address: String!
    var district: String!
    var city: String!
    var state: String!
    var zipCode: String!
    
    init(name: String, description: String, email: String, contact: String, phone: String,
         bank: String, agency: String, accountNumber: String, address: String, district: String,
         city: String, state: String, zipCode: String) {
        
        self.name = name
        self.description = description
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
    }
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        name            <- map["Name"]
        description     <- map["description"]
        email           <- map["e_mail"]
        contact         <- map["contato"]
        phone           <- map["telefone"]
        bank            <- map["banco"]
        agency          <- map["agencia"]
        accountNumber   <- map["conta"]
        address         <- map["endereco"]
        district        <- map["bairro"]
        city            <- map["cidade"]
        state           <- map["estado"]
        zipCode         <- map["cep"]
    }
    
//    Once your class implements Mappable, ObjectMapper allows you to easily convert to and from JSON.
//    
//    Convert a JSON string to a model object:
//    
//    let user = User(JSONString: JSONString)
//    Convert a model object to a JSON string:
//    
//    let JSONString = user.toJSONString(prettyPrint: true)
//    Alternatively, the Mapper.swift class can also be used to accomplish the above (it also provides extra functionality for other situations):
//    
//    // Convert JSON String to Model
//    let user = Mapper<User>().map(JSONString: JSONString)
//    // Create JSON String from Model
//    let JSONString = Mapper().toJSONString(user, prettyPrint: true)
//    
}
