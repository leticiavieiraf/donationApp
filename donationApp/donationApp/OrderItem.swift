//
//  OrderItem.swift
//  donationApp
//
//  Created by Leticia Vieira Fernandes on 15/04/17.
//  Copyright © 2017 PUC. All rights reserved.
//

import UIKit
import FirebaseDatabase

struct OrderItem {
    
    var key: String
    var name: String
    var addedByUser: String
    var userUid: String
    var userEmail: String
    var userPhotoUrl: String
    var publishDate: String
    var ref: DatabaseReference?
    
    init (name: String, addedByUser: String, userUid: String, userEmail: String, userPhotoUrl: String, publishDate: String, key: String = "") {
        self.key = key
        self.name = name
        self.addedByUser = addedByUser
        self.userUid = userUid
        self.userEmail = userEmail
        self.userPhotoUrl = userPhotoUrl
        self.publishDate = publishDate
        self.ref = nil
    }
    
    init(snapshot: DataSnapshot) {
        key = snapshot.key
        if !(snapshot.value is NSNull) {
            let snapshotValue = snapshot.value as! [String: AnyObject]
            name = snapshotValue["name"] as! String
            addedByUser = snapshotValue["addedByUser"] as! String
            userUid = snapshotValue["userUid"] as! String
            userEmail = snapshotValue["userEmail"] as! String
            userPhotoUrl = snapshotValue["userPhotoUrl"] as! String
            publishDate = snapshotValue["publishDate"] as! String
            ref = snapshot.ref
        } else {
            name = "Erro"
            addedByUser = "Erro"
            userUid = "Erro"
            userEmail = "Erro"
            userPhotoUrl = "Erro"
            publishDate = "Erro"
            ref = nil
        }
    }
    
    func toAnyObject() -> Any {
        return [
            "name": name,
            "addedByUser": addedByUser,
            "userUid": userUid,
            "userEmail": userEmail,
            "userPhotoUrl": userPhotoUrl,
            "publishDate": publishDate
            
        ]
    }
}
