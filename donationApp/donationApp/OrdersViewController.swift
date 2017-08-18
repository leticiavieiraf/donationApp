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
    var allOrders: [OrderItem] = []
    var sweaters: [OrderItem] = []
    var food: [OrderItem] = []
    var shoes: [OrderItem] = []
    var hygieneProducts: [OrderItem] = []
    var clothes: [OrderItem] = []
    var sections: [String] = []
    var selectedItem : OrderItem?
    
    // firebase variables
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
            loadAllOrders()
        } else {
            Helper.redirectToLogin()
        }
    }
    
    // MARK: - Check Login method
    func userLoggedIn() -> Bool {
        let donatorUserLoggedIn = Helper.donatorUserLoggedIn()
        var isLogged = true
        
        if !donatorUserLoggedIn {
            isLogged = false
            print("Facebook: User IS NOT logged in!")
            print("Firebase: User IS NOT logged in!")
        }
        return isLogged
    }
    
    // MARK: - Setup TabBarController methods
    func setupTabBarController() {
        self.tabBarController?.title = "Pedidos"
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        self.tabBarController?.navigationItem.leftBarButtonItem = nil
        self.tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - Firebase methods
    func loadAllOrders() {
        
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.show()
        
        refOrderItems.child("users-uid").observe(.value, with: { (snapshot) in
            var count = 0
            var userIdKeys: [String] = []
            var orders: [OrderItem] = []
            
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
                    if (count == userIdKeys.count) {
                        self.allOrders = orders
                        self.setupDataSource()
                        
                        SVProgressHUD.dismiss()
                    }
                })
            }
        })
    }
    
    func getInstitutionUserForSelectedOrderAndShowDetails(_ orderItem: OrderItem) {
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.show()
        
        let userUID = orderItem.userUid
        refInstitutionUsers.child(userUID.lowercased()).observeSingleEvent(of: .value, with: { (snapshot) in
            SVProgressHUD.dismiss()
            
            let user = InstitutionUser(snapshot: snapshot)
            self.redirectToMapViewController(user)
        })
    }
    
    // MARK: - Redirect methods
    func redirectToMapViewController(_ institutionUser: InstitutionUser) {
        self.performSegue(withIdentifier: "showMap", sender: institutionUser)
    }
    
    // MARK: Navigation methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMap" {
            let mapViewController = segue.destination as! MapViewController
            mapViewController.selectedInstitutionUser = sender as? InstitutionUser
        }
    }
    
    // MARK: - Setup Data Source methods
    func setupDataSource() {
        resetDataSource()
        
        sections =  [Constants.kSweaters,
                     Constants.kFood,
                     Constants.kShoes,
                     Constants.kHygieneProducts,
                     Constants.kClothes]
        
        for order in allOrders {
            switch order.name {
                case Constants.kSweaters:
                    sweaters.append(order)
                case Constants.kFood:
                    food.append(order)
                case Constants.kShoes:
                    shoes.append(order)
                case Constants.kHygieneProducts:
                    hygieneProducts.append(order)
                case Constants.kClothes:
                    clothes.append(order)
                default:
                    allOrders.append(order)
            }
        }
        self.tableView.reloadData()
    }
    
    func resetDataSource() {
        sections.removeAll()
        sweaters.removeAll()
        food.removeAll()
        shoes.removeAll()
        hygieneProducts.removeAll()
        clothes.removeAll()
    }
    
    // MARK: - Setup TableView methods
    func getNumberOfRowsForSection(_ sectionTitle: String) -> Int {
        switch sectionTitle {
            case Constants.kSweaters:
                return sweaters.count
            case Constants.kFood:
                return food.count
            case Constants.kShoes:
                return shoes.count
            case Constants.kHygieneProducts:
                return hygieneProducts.count
            case Constants.kClothes:
                return clothes.count
            default:
                return allOrders.count
        }
    }
    
    func getOrderForRowAtIndexPath(_ indexPath: IndexPath) -> OrderItem {
        let sectionTitle = sections[indexPath.section]
        var orderItem: OrderItem
        
        switch sectionTitle {
            case Constants.kSweaters:
                orderItem = sweaters[indexPath.row]
            case Constants.kFood:
                orderItem = food[indexPath.row]
            case Constants.kShoes:
                orderItem = shoes[indexPath.row]
            case Constants.kHygieneProducts:
                orderItem = hygieneProducts[indexPath.row]
            case Constants.kClothes:
                orderItem = clothes[indexPath.row]
            default:
                orderItem = allOrders[indexPath.row]
        }
        return orderItem
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionTitle = sections[section]
        let numberOfRows = getNumberOfRowsForSection(sectionTitle)
        
        return numberOfRows
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "orderPostCell", for: indexPath) as! ItemsTableViewCell
        let orderItem = getOrderForRowAtIndexPath(indexPath)
        
        cell.profileImageView.image = UIImage(named: "institution-big")
        cell.itemNameLabel.text = "Precisamos de " + orderItem.name.lowercased() + "!"
        cell.userNameLabel.text = orderItem.addedByUser
        cell.userEmailLabel.text = orderItem.userEmail
        let publishDate = Helper.dateFrom(string: orderItem.publishDate, format: "dd/MM/yyyy HH:mm")
        cell.publishDateLabel.text = Helper.periodBetween(date1: publishDate, date2: Date())
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let orderItem = getOrderForRowAtIndexPath(indexPath);
        getInstitutionUserForSelectedOrderAndShowDetails(orderItem)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
