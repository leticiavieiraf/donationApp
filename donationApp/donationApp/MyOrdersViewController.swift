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
import SVProgressHUD

class MyOrdersViewController: UIViewController, UITableViewDataSource, ItemSelectionDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var emptyView: UIView!
    
    var items : [OrderItem] = []
    var institutionUser : InstitutionUser!
    let refOrderItems = Database.database().reference(withPath: "order-items")
    let refInstitutionUsers = Database.database().reference(withPath: "institution-users")
    
    // MARK: - Life Cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupTabBarController()
        
        if userLoggedIn() {
            if let currentUser = self.institutionUser {
                loadOrdersFrom(currentUser.uid)
            } else {
                getUserAndLoadOrders()
            }
        } else {
            Helper.redirectToLogin()
        }
    }
    
    // MARK: - Check Login methods
    func userLoggedIn() -> Bool {
        let institutionUserLoggedIn = Helper.institutionUserLoggedIn()
        var isLogged = true
        
        if !institutionUserLoggedIn {
            isLogged = false
            print("Firebase: User IS NOT logged in!")
        }
        return isLogged
    }
    
    // MARK: - Setup TabBarController methods
    func setupTabBarController() {
        self.tabBarController?.title = "Meus Pedidos"
        let addButton = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(showNewOrderPopUp))
        self.tabBarController?.navigationItem.rightBarButtonItem = addButton
        self.tabBarController?.navigationItem.leftBarButtonItem = nil
        self.tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - Firebase methods
    func getUserAndLoadOrders() {
        
        getUser { (user) in
            self.institutionUser = user
            self.loadOrdersFrom(self.institutionUser.uid)
        }
    }
    
    func loadOrdersFrom(_ userUID: String) {
        
        getUserOrders(userUID) { (userOrders) in
            self.items = userOrders
            self.setupLayout()
        }
    }
    
    func getUser(onSuccess: @escaping (_ user: InstitutionUser) -> ()) {
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.show()
        
        let userUID = Auth.auth().currentUser?.uid
        refInstitutionUsers.child(userUID!.lowercased()).observeSingleEvent(of: .value, with: { (snapshot) in
            SVProgressHUD.dismiss()

            let user = InstitutionUser(snapshot: snapshot)
            onSuccess(user)
        })
    }
    
    func getUserOrders(_ userIdKey: String, onSuccess: @escaping (_ userOrders: [OrderItem]) -> ()) {
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.show()
        
        refOrderItems.child("users-uid").child(userIdKey.lowercased()).observe(.value, with: { (snapshot) in
            SVProgressHUD.dismiss()
            var userOrders: [OrderItem] = []
            
            for item in snapshot.children.allObjects {
                let orderItem = OrderItem(snapshot: item as! DataSnapshot)
                userOrders.append(orderItem)
            }
            onSuccess(userOrders)
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
    
    // MARK: - Setup Layout methods
    func setupLayout() {
        if items.count == 0 {
            presentEmptyView()
        } else {
            hideEmptyView()
            tableView.reloadData()
        }
    }
    
    func presentEmptyView() {
        emptyView.frame = view.frame
        view.addSubview(emptyView)
        view.layoutIfNeeded()
    }
    
    func hideEmptyView() {
        emptyView.removeFromSuperview()
        view.layoutIfNeeded()
    }
    
    // MARK: - Popup New Order
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
    
    // MARK: - UITableViewDataSource
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "orderCell", for: indexPath) as! MyItemsTableViewCell
        let orderItem = items[indexPath.row]
        
        cell.labelTitle?.text = orderItem.name
        let publishDate = Helper.dateFrom(string: orderItem.publishDate, format: "dd/MM/yyyy HH:mm")
        cell.labelSubtitle?.text = Helper.periodBetween(date1: publishDate, date2: Date())
        
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
