//
//  MyDonationsViewController.swift
//  donationApp
//
//  Created by Letícia Fernandes on 11/03/17.
//  Copyright © 2017 PUC. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FacebookLogin
import FacebookCore

class MyDonationsViewController: UIViewController, UITableViewDataSource, ItemSelectionDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var items : [DonationItem] = []
    var donatorUser : DonatorUser!
    let refDonationItems = FIRDatabase.database().reference(withPath: "donation-items")
    
    // MARK: Life Cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.title = "Minhas Doações"
        let addButton = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(showNewDonationPopUp))
        self.tabBarController?.navigationItem.rightBarButtonItem = addButton
        
        if AccessToken.current == nil || FIRAuth.auth()?.currentUser == nil {
            print("Facebook: User IS NOT logged in!")
            print("Firebase: User IS NOT logged in!")
            
            // Redireciona para tela de login
            let loginNav = UIStoryboard(name: "Main", bundle:nil).instantiateInitialViewController()
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = loginNav
            
        } else {
            if let currentUser = self.donatorUser {
                loadDonationsFrom(currentUser.uid)
            } else {
                getUserAndLoadDonations()
            }
        }
    }
    
    // MARK: Firebase methods
    func getUserAndLoadDonations() {
        
        FIRAuth.auth()!.addStateDidChangeListener { auth, user in
            guard let user = user else { return }
            
            if AccessToken.current != nil {
                self.donatorUser = DonatorUser(authData: user)
                self.loadDonationsFrom(self.donatorUser.uid)
            }
        }
    }
    
    func loadDonationsFrom(_ userUID: String) {
        
       refDonationItems.child("users-uid").child(userUID.lowercased()).observe(.value, with: { snapshot in
            var newItems: [DonationItem] = []
            
            for item in snapshot.children.allObjects {
                let donationItem = DonationItem(snapshot: item as! FIRDataSnapshot)
                newItems.append(donationItem)
            }
            
            self.items = newItems
            self.tableView.reloadData()
        })
    }
    
    func insert(donation: String) {
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        let dateStr = formatter.string(from: date)
        
        
        let donationItem = DonationItem(name: donation,
                                        addedByUser: donatorUser.name,
                                        userUid: donatorUser.uid,
                                        userEmail: donatorUser.email,
                                        userPhotoUrl: donatorUser.photoUrl,
                                        publishDate: dateStr)
        
        let donationItemRef = refDonationItems.child("users-uid").child(donationItem.userUid.lowercased()).childByAutoId()
        donationItemRef.setValue(donationItem.toAnyObject())
    }
    
    // MARK: Popup New Donation
    func showNewDonationPopUp() {
     
        let newDonationVC = UIStoryboard(name: "Donators", bundle:nil).instantiateViewController(withIdentifier: "sbPopUpID") as! NewDonationViewController
        newDonationVC.delegate = self
        
        self.addChildViewController(newDonationVC)
        newDonationVC.view.frame = self.view.frame
        self.view.addSubview(newDonationVC.view)
        newDonationVC.didMove(toParentViewController: self)
    }
    
    func didPressSaveWithSelectItem(_ item: String) {
        insert(donation:item)
    }
    
    // MARK: UITableViewDataSource
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "donationCell", for: indexPath)
        let donationItem = items[indexPath.row]
        
        cell.textLabel?.text = donationItem.name
        cell.detailTextLabel?.text = "Publicado em " + donationItem.publishDate
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
      
        if editingStyle == .delete {
            let donationItem = items[indexPath.row]
            donationItem.ref?.removeValue()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
