//
//  MyOrdersViewController.swift
//  donationApp
//
//  Created by Letícia Fernandes on 14/04/17.
//  Copyright © 2017 PUC. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FacebookLogin
import FacebookCore

class MyOrdersViewController: UIViewController, UITableViewDataSource, ItemSelectionDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var items : [DonationItem] = []
    var institutionUser : InstitutionUser!
    let refDonationItems = FIRDatabase.database().reference(withPath: "order-items")
    
    // MARK: Life Cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if AccessToken.current == nil || FIRAuth.auth()?.currentUser == nil {
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.title = "Minhas Doações"
        let addButton = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(showNewDonationPopUp))
        self.tabBarController?.navigationItem.rightBarButtonItem = addButton
        
    }
    
    // MARK: Firebase methods
    func loadDonations() {
        
        // Busca doações
        FIRAuth.auth()!.addStateDidChangeListener { auth, user in
            guard let user = user else { return }
            self.institutionUser = InstitutionUser(authData: user)
        }
        
        refDonationItems.observe(.value, with: { snapshot in
            
            var newItems: [DonationItem] = []
            
            for item in snapshot.children {
                let orderItem = DonationItem(snapshot: item as! FIRDataSnapshot)
                newItems.append(orderItem)
            }
            
            self.items = newItems
            self.tableView.reloadData()
        })
    }
    
    func insert(order: String) {
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
        let dateStr = formatter.string(from: date)
        
        
        let orderItem = DonationItem(name: order,
                                        addedByUser: institutionUser.name,
                                        userUid: institutionUser.uid,
                                        userEmail: institutionUser.email,
                                        userPhotoUrl:"",
                                        publishDate: dateStr)
        
        let orderItemRef = self.refDonationItems.child(orderItem.userUid.lowercased() + " - " + orderItem.name)//.childByAutoId()
        orderItemRef.setValue(orderItem.toAnyObject())
    }
    
    // MARK: Popup New Donation
    func showNewDonationPopUp() {
        
        let newDonationVC = UIStoryboard(name: "Institutions", bundle:nil).instantiateViewController(withIdentifier: "sbPopUpID") as! NewDonationViewController
        newDonationVC.delegate = self
        
        self.addChildViewController(newDonationVC)
        newDonationVC.view.frame = self.view.frame
        self.view.addSubview(newDonationVC.view)
        newDonationVC.didMove(toParentViewController: self)
    }
    
    func didPressSaveWithSelectItem(_ item: String) {
        insert(order:item)
    }
    
    // MARK: UITableViewDataSource
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return items.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "orderCell", for: indexPath)
        let orderItem = items[indexPath.row]
        
        cell.textLabel?.text = orderItem.name
        cell.detailTextLabel?.text = "Publicado em " + orderItem.publishDate
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let orderItem = items[indexPath.row]
            orderItem.ref?.removeValue()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
