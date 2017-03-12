//
//  DonationItem.swift
//  donationApp
//
//  Created by Natalia Sheila Cardoso de Siqueira on 11/03/17.
//  Copyright © 2017 PUC. All rights reserved.
//

import Foundation
import Firebase

struct DonationItem {
    
    var key: String
    var name: String
    var donator: DonatorUser
    var publishDate: String
    var ref: FIRDatabaseReference?
    
//    var donatorName: String
//    var donatorEmail: String
//    var donatorPhotoUrl: String
    
    
    init (name: String, donator: DonatorUser, publishDate: String, key: String = "") {
        self.key = key
        self.name = name
        self.donator = donator
        self.publishDate = publishDate
        self.ref = nil
    }
    
    init(snapshot: FIRDataSnapshot) {
        key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        name = snapshotValue["name"] as! String
        donator = snapshotValue["donator"] as! DonatorUser
        publishDate = snapshotValue["publishDate"] as! String
        ref = snapshot.ref
    }
    
    func toAnyObject() -> Any {
        return [
            "name": name,
            "publishDate": publishDate
        ]
    }
}

//"donator": donator,
