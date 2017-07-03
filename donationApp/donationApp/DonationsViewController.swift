//
//  DonationsViewController.swift
//  donationApp
//
//  Created by Letícia Fernandes on 14/04/17.
//  Copyright © 2017 PUC. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import SVProgressHUD
import AVFoundation

class DonationsViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var items: [DonationItem] = []
    let refDonationItems = Database.database().reference(withPath: "donation-items")

    // MARK: Life Cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.title = "Doações"
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
    
        if Auth.auth().currentUser == nil {
            print("Facebook: User IS NOT logged in!")
            print("Firebase: User IS NOT logged in!")
            
            // Redireciona para tela de login
            let loginNav = UIStoryboard(name: "Main", bundle:nil).instantiateInitialViewController()
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = loginNav
            
        } else {
            loadDonations()
        }
    }
    
    // MARK: Firebase methods
    func loadDonations() {
        
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.show()
        
        refDonationItems.child("users-uid").observe(.value, with: { (snapshot) in
            var count = 0
            var userIdKeys = [String]()
            var donations : [DonationItem] = []
            
            for item in snapshot.children.allObjects {
                let userId = item as! DataSnapshot
                userIdKeys.append(String(userId.key))
            }
            
            for userIdKey in userIdKeys {
                self.refDonationItems.child("users-uid").child(userIdKey.lowercased()).observe(.value, with: { (snapshot) in
                    
                    for item in snapshot.children.allObjects {
                        let donationItem = DonationItem(snapshot: item as! DataSnapshot)
                        donations.append(donationItem)
                    }
                    
                    count += 1
                    if count == userIdKeys.count {
                        self.items = donations
                        self.tableView.reloadData()
                        SVProgressHUD.dismiss()
                    }
                })
            }
        })
    }

    // MARK: UITableViewDataSource
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "donationPostCell", for: indexPath) as! ItemsTableViewCell
        let donationItem = items[indexPath.row]
        
        cell.itemNameLabel.text = donationItem.name
        cell.userNameLabel.text = donationItem.addedByUser
        cell.userEmailLabel.text = donationItem.userEmail
        cell.publishDateLabel.text = "Publicado em " + donationItem.publishDate
        
        do {
            try cell.loadImageWith(donationItem.userPhotoUrl)
        
        } catch let loadingImageError as NSError {
            
            print(loadingImageError.localizedDescription)
            cell.profileImage.image = UIImage(named: "user-big")
        }
        
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
