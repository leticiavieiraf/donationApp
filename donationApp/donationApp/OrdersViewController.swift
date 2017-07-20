//
//  OrdersViewController.swift
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
import SVProgressHUD

class OrdersViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var items: [OrderItem] = []
    let refOrderItems = Database.database().reference(withPath: "order-items")
    
    // MARK: Life Cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.title = "Pedidos"
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        
        if AccessToken.current == nil || Auth.auth().currentUser == nil {
            print("Facebook: User IS NOT logged in!")
            print("Firebase: User IS NOT logged in!")
            
            // Redireciona para tela de login
            let loginNav = UIStoryboard(name: "Main", bundle:nil).instantiateInitialViewController()
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = loginNav
            
        } else {
            loadAllOrders()
        }
    }
    
    // MARK: Firebase methods
    func loadAllOrders() {
        
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.show()
        
        refOrderItems.child("users-uid").observe(.value, with: { (snapshot) in
            var count = 0
            var userIdKeys = [String]()
            var orders : [OrderItem] = []
            
            for item in snapshot.children.allObjects {
                let userId = item as! DataSnapshot
                userIdKeys.append(String(userId.key))
            }
            
            for userIdKey in userIdKeys {
                self.refOrderItems.child("users-uid").child(userIdKey.lowercased()).observe(.value, with: { (snapshot) in
                    
                    for item in snapshot.children.allObjects {
                        let orderItem = OrderItem(snapshot: item as! DataSnapshot)
                        orders.append(orderItem)
                    }
                    
                    count += 1
                    if count == userIdKeys.count {
                        self.items = orders
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "orderPostCell", for: indexPath) as! ItemsTableViewCell
        let orderItem = items[indexPath.row]
        
        cell.itemNameLabel.text = orderItem.name
        cell.userNameLabel.text = orderItem.addedByUser
        cell.userEmailLabel.text = orderItem.userEmail
        cell.publishDateLabel.text = "Publicado em " + orderItem.publishDate
        cell.profileImageView.image = UIImage(named: "institution-big")
        
        return cell
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
