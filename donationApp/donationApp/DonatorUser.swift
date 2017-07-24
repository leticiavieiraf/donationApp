//
//  DonatorUser.swift
//  donationApp
//
//  Created by Letícia Fernandes on 11/03/17.
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
    var ref: DatabaseReference?
    
    init(authData: User) {
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
    
    
    init(snapshot: DataSnapshot) {
        key = snapshot.key
        if !(snapshot.value is NSNull) {
            let snapshotValue = snapshot.value as! [String: AnyObject]
            uid = snapshotValue["uid"] as! String
            email = snapshotValue["email"] as! String
            name = snapshotValue["name"] as! String
            photoUrl = snapshotValue["photoUrl"] as! String
            ref = snapshot.ref
        } else {
            uid = "Erro"
            email = "Erro"
            name = "Erro"
            photoUrl = "Erro"
            ref = nil
        }
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
