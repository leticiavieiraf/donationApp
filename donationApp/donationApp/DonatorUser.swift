//
//  DonatorUser.swift
//  donationApp
//
//  Created by Natalia Sheila Cardoso de Siqueira on 11/03/17.
//  Copyright © 2017 PUC. All rights reserved.
//

import Foundation
import Firebase

struct DonatorUser {
    
    let key: String
    let uid: String
    let email: String
    let name: String
    let photoUrl: String
    var ref: FIRDatabaseReference?
    
    init(authData: FIRUser) {
        key = ""
        uid = authData.uid
        email = authData.email!
        name = authData.displayName!
        photoUrl = (authData.photoURL?.absoluteString)!
        ref = nil
    }
    
    init(uid: String, email: String, name: String, photoUrl: String, key: String = "") {
        self.key = key
        self.uid = uid
        self.email = email
        self.name = name
        self.photoUrl = photoUrl
        self.ref = nil
    }
    
    
    init(snapshot: FIRDataSnapshot) {
        key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        uid = snapshotValue["uid"] as! String
        email = snapshotValue["email"] as! String
        name = snapshotValue["name"] as! String
        photoUrl = snapshotValue["photoUrl"] as! String
        ref = snapshot.ref
    }
    
    func toAnyObject() -> Any {
        return [
            "uid": uid,
            "email": email,
            "name": name,
            "photoUrl": photoUrl
        ]
    }
    
}
