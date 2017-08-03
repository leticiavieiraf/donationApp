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

class OrdersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //outlets
    @IBOutlet weak var tableView: UITableView!
    
    // variables
    var items: [OrderItem] = []
    var selectedItem : OrderItem?
    let refOrderItems = Database.database().reference(withPath: "order-items")
    let refInstitutionUsers = Database.database().reference(withPath: "institution-users")
    
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
    
    func getInstitutionUserForSelectedOrder(_ orderItem: OrderItem) {
        
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.show()
        
        let userUID = orderItem.userUid
        
        refInstitutionUsers.child(userUID.lowercased()).observeSingleEvent(of: .value, with: { (snapshot) in
            SVProgressHUD.dismiss()
            
            let user = InstitutionUser(snapshot: snapshot)
            
            if let mapVC = self.storyboard?.instantiateViewController(withIdentifier: "MapViewControllerID") as? MapViewController {
                mapVC.selectedInstitutionUser = user
                if let navigator = self.navigationController {
                    navigator.pushViewController(mapVC, animated: true)
                }
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
    
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let orderItem = items[indexPath.row];
        getInstitutionUserForSelectedOrder(orderItem)
        
//        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NewsDetailsVCID") as? NewsDetailsViewController {
//            viewController.newsObj = newsObj
//            if let navigator = navigationController {
//                navigator.pushViewController(viewController, animated: true)
//            }
//        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
