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

class MyOrdersViewController: UIViewController, UITableViewDataSource, ItemSelectionDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var items : [OrderItem] = []
    var institutionUser : InstitutionUser!
    let refOrderItems = FIRDatabase.database().reference(withPath: "order-items")
    let refInstitutionUsers = FIRDatabase.database().reference(withPath: "institution-users")
    
    // MARK: Life Cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.title = "Meus Pedidos"
        let addButton = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(showNewOrderPopUp))
        self.tabBarController?.navigationItem.rightBarButtonItem = addButton
        
        
        if FIRAuth.auth()?.currentUser == nil {
            print("Facebook: User IS NOT logged in!")
            print("Firebase: User IS NOT logged in!")
            
            // Redireciona para tela de login
            let loginNav = UIStoryboard(name: "Main", bundle:nil).instantiateInitialViewController()
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = loginNav
            
        } else {
           
            if let currentUser = self.institutionUser {
                loadOrdersFrom(currentUser.uid)
            } else {
                getUserAndLoadOrders()
            }
        }
        
    }
    
    // MARK: Firebase methods
    func getUserAndLoadOrders() {
        
        let userUID = FIRAuth.auth()?.currentUser?.uid
        
        refInstitutionUsers.child(userUID!).observeSingleEvent(of: .value, with: { (snapshot) in
            self.institutionUser = InstitutionUser(snapshot: snapshot)
            self.loadOrdersFrom(self.institutionUser.uid)
        })
        
    }
    
    func loadOrdersFrom(_ userUID: String) {
        
        refOrderItems.child("users-uid").child(userUID.lowercased()).observe(.value, with: { (snapshot) in
            var newItems: [OrderItem] = []
            
            for item in snapshot.children.allObjects {
                let orderItem = OrderItem(snapshot: item as! FIRDataSnapshot)
                newItems.append(orderItem)
            }
            
            self.items = newItems
            self.tableView.reloadData()
        })
    }
    
    func insert(order: String) {
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        let dateStr = formatter.string(from: date)
        
        
        let orderItem = OrderItem(name: order,
                                     addedByUser: institutionUser.name,
                                     userUid: institutionUser.uid,
                                     userEmail: institutionUser.email,
                                     userPhotoUrl:"",
                                     publishDate: dateStr)
        
        let orderItemRef = refOrderItems.child("users-uid").child(orderItem.userUid.lowercased()).childByAutoId()
        orderItemRef.setValue(orderItem.toAnyObject())
    }
    
    // MARK: Popup New Order
    func showNewOrderPopUp() {
        
        let newOrderVC = UIStoryboard(name: "Institutions", bundle:nil).instantiateViewController(withIdentifier: "sbPopUpID") as! NewOrderViewController
        newOrderVC.delegate = self
        
        self.addChildViewController(newOrderVC)
        newOrderVC.view.frame = self.view.frame
        self.view.addSubview(newOrderVC.view)
        newOrderVC.didMove(toParentViewController: self)
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
