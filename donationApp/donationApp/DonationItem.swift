//
//  DonationItem.swift
//  donationApp
//
//  Created by Letícia Fernandes on 11/03/17.
//  Copyright © 2017 PUC. All rights reserved.
//

import Foundation
import Firebase

struct DonationItem {
    
    var key: String
    var name: String
    var addedByUser: String
    var userUid: String
    var userEmail: String
    var userPhotoUrl: String
    var publishDate: String
    var ref: FIRDatabaseReference?
    
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
    
    init(snapshot: FIRDataSnapshot) {
        key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
//        let snapshotValue = snapshot.value as! [String: Any]
//        let value = snapshotValue[snapshotValue.keys.first!]
//        let itemdic = snapshotValue as Dictionary<String, Any>
        name = snapshotValue["name"] as! String
        addedByUser = snapshotValue["addedByUser"] as! String
        userUid = snapshotValue["userUid"] as! String
        userEmail = snapshotValue["userEmail"] as! String
        userPhotoUrl = snapshotValue["userPhotoUrl"] as! String
        publishDate = snapshotValue["publishDate"] as! String
        ref = snapshot.ref
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
