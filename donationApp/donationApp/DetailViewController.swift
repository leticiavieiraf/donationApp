//
//  DetailViewController.swift
//  donationApp
//
//  Created by Letícia on 21/07/17.
//  Copyright © 2017 PUC. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class DetailViewController: UIViewController, UITableViewDataSource {
    
    // outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    // constraints
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var viewCollapseDetailsHeightConstraint: NSLayoutConstraint!
    
    // variables
    var institution = Institution()
    var institutionUser : InstitutionUser?
    var orders: [OrderItem] = []
    
    // firebase refs
    let refOrderItems = Database.database().reference(withPath: "order-items")
    let refInstitutionsUsers = Database.database().reference(withPath: "institution-users")
    
    // MARK: Life Cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: Setup Data Source methods
    func loadData() {
        if let institutionUser = self.institutionUser {
            institution = Helper.institution(from: institutionUser)
            setupDetailBox()
            loadOrdersFrom(institutionUser.uid)
        } else {
            getInstitutionUserAndLoadOrders()
        }
    }
    
    func setupDetailBox() {
        self.nameLabel.text = institution.name != "" ? institution.name : "-"
        self.emailLabel.text = institution.email != "" ? institution.email : "-"
        self.addressLabel.text = Helper.institutionAddress(institution)
        self.infoLabel.text = institution.group != "" ? institution.group : "-"
        self.phoneLabel.text = institution.phone != "" ? institution.phone : "-"
    }

    func imageNameForItem(_ itemName: String) -> String {
        switch itemName {
        case Constants.kSweaters:
            return "agasalhos"
        case Constants.kFood:
            return "alimentos"
        case Constants.kShoes:
            return "calcados"
        case Constants.kHygieneProducts:
            return "higiene"
        case Constants.kClothes:
            return "roupas"
        default:
            return "empty"
        }
    }

    // MARK: Firebase methods
    func getInstitutionUserAndLoadOrders() {
        
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.show()
        
        refInstitutionsUsers.observe(.value, with: { snapshot in
            SVProgressHUD.dismiss()
            
            for item in snapshot.children {
                let user = InstitutionUser(snapshot: item as! DataSnapshot)
                 
                if self.institution.email == user.email  {
                    self.institutionUser = user
                }
            }
            
            if let foundUser = self.institutionUser {
                self.institution = Helper.institution(from: foundUser)
                self.setupDetailBox()
                self.loadOrdersFrom(foundUser.uid)
            } else {
                self.setupDetailBox()
                self.orders = []
                self.reloadTableView()
            }
        })
    }
    
    func loadOrdersFrom(_ userUID: String) {
    
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.show()
        
        refOrderItems.child("users-uid").child(userUID.lowercased()).observe(.value, with: { (snapshot) in
            SVProgressHUD.dismiss()
            var userItems: [OrderItem] = []
            
            for item in snapshot.children.allObjects {
                let orderItem = OrderItem(snapshot: item as! DataSnapshot)
                userItems.append(orderItem)
            }
            
            self.orders = userItems
            self.reloadTableView()
        })
    }
    
    // MARK: Setup Layout methods
    func setupTableViewHeight() {
        var height : CGFloat = 55
        
        if self.orders.count > 0 {
            height =  CGFloat(55 * self.orders.count)
        }
        self.tableViewHeight.constant = height
        self.view.layoutIfNeeded()
    }
    
    func reloadTableView() {
        self.setupTableViewHeight()
        self.tableView.reloadData()
    }
    
    func showButtonCollapseDetails() {
        viewCollapseDetailsHeightConstraint.constant = 43.0
        self.view.layoutIfNeeded()
    }
    
    func hideButtonCollapseDetails() {
        viewCollapseDetailsHeightConstraint.constant = 0
        self.view.layoutIfNeeded()
    }
    
    // MARK: Action methods
    @IBAction func collapseDetails(_ sender: Any) {
        self.institutionUser = nil
        
        let mapViewController = parent as! MapViewController
        mapViewController.collapseDetails()
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows = 1
        
        if orders.count > 0 {
            numberOfRows = orders.count
        }
        
        return numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailOrderCell", for: indexPath) as! MyItemsTableViewCell
    
        if orders.count > 0 {
            let orderItem = orders[indexPath.row]
            
            cell.imageViewIcon.image = UIImage(named: imageNameForItem(orderItem.name))
            cell.labelTitle?.text = orderItem.name
            let publishDate = Helper.dateFrom(string: orderItem.publishDate, format: "dd/MM/yyyy HH:mm")
            cell.labelSubtitle.text = Helper.periodBetween(date1: publishDate, date2: Date())
            
            return cell
        } else {
            cell.imageViewIcon.image = UIImage(named: imageNameForItem(""))
            cell.labelTitle?.text = "Não há pedidos cadastrados."
            cell.labelSubtitle?.text = ""
            
            return cell
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
