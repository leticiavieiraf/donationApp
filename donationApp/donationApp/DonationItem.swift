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
    var addedByUser: String
    var userEmail: String
    var userPhotoUrl: String
    var publishDate: String
    var ref: FIRDatabaseReference?
    
    init (name: String, addedByUser: String, userEmail: String, userPhotoUrl: String, publishDate: String, key: String = "") {
        self.key = key
        self.name = name
        self.addedByUser = addedByUser
        self.userEmail = userEmail
        self.userPhotoUrl = userPhotoUrl
        self.publishDate = publishDate
        self.ref = nil
    }
    
    init(snapshot: FIRDataSnapshot) {
        key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        name = snapshotValue["name"] as! String
        addedByUser = snapshotValue["addedByUser"] as! String
        userEmail = snapshotValue["userEmail"] as! String
        userPhotoUrl = snapshotValue["userPhotoUrl"] as! String
        publishDate = snapshotValue["publishDate"] as! String
        ref = snapshot.ref
    }
    
    func toAnyObject() -> Any {
        return [
            "name": name,
            "addedByUser": addedByUser,
            "userEmail": userEmail,
            "userPhotoUrl": userPhotoUrl,
            "publishDate": publishDate
            
        ]
    }
}
