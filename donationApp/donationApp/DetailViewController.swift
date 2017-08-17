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
    
    // variables
    var institution = Institution()
    var institutionUser : InstitutionUser?
    var items: [OrderItem] = []
    
    // firebase refs
    let refOrderItems = Database.database().reference(withPath: "order-items")
    let refInstitutionsUsers = Database.database().reference(withPath: "institution-users")
    
    // MARK: - Life Cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Auth.auth().currentUser == nil {
            print("Facebook: User IS NOT logged in!")
            print("Firebase: User IS NOT logged in!")
            
            // Redireciona para tela de login
            let loginNav = UIStoryboard(name: "Main", bundle:nil).instantiateInitialViewController()
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = loginNav
        }
    }
    
    // MARK: - Data Source methods
    func loadData() {
        if let institutionUser = self.institutionUser {
            setupDetailBox(institutionUser, nil)
            loadOrdersFrom(institutionUser.uid)
        } else {
            getInstitutionUserAndLoadOrders()
        }
    }

    // MARK: - Firebase methods
    func getInstitutionUserAndLoadOrders() {
        
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.show()
        
        refInstitutionsUsers.observe(.value, with: { snapshot in
            
            for item in snapshot.children {
                let user = InstitutionUser(snapshot: item as! DataSnapshot)
                 
                if self.institution.email == user.email  {
                    self.institutionUser = user
                }
            }
            
            if let foundUser = self.institutionUser {
                self.setupDetailBox(foundUser, nil)
                self.loadOrdersFrom(foundUser.uid)
            } else {
                self.setupDetailBox(nil, self.institution)
                self.loadOrdersFrom(nil)
                SVProgressHUD.dismiss()
            }
        })
    }
    
    func loadOrdersFrom(_ userUID: String?) {
        
        if let userUID = userUID {
            refOrderItems.child("users-uid").child(userUID.lowercased()).observe(.value, with: { (snapshot) in
                
                var userItems: [OrderItem] = []
                
                for item in snapshot.children.allObjects {
                    let orderItem = OrderItem(snapshot: item as! DataSnapshot)
                    userItems.append(orderItem)
                }
                
                self.items = userItems
                self.setupTableViewHeight()
                
                SVProgressHUD.dismiss()
            })
        } else {
            self.items = []
            self.setupTableViewHeight()
        }
    }
    
    // MARK: - Setup methods
    func setupDetailBox(_ institutionUser: InstitutionUser?, _ institution: Institution?) {
        
        if let institution = institution {
            self.nameLabel.text = institution.name != "" ? institution.name : "-"
            self.emailLabel.text = institution.email != "" ? institution.email : "-"
            self.addressLabel.text = Helper.institutionAddress(institution)
            self.infoLabel.text = institution.group != "" ? institution.group : "-"
            self.phoneLabel.text = institution.phone != "" ? institution.phone : "-"
            
        } else if let institution = institutionUser {
                self.nameLabel.text = institution.name != "" ? institution.name : "-"
                self.emailLabel.text = institution.email != "" ? institution.email : "-"
                self.addressLabel.text = Helper.institutionUserAddress(institution)
                self.infoLabel.text = institution.group != "" ? institution.group : "-"
                self.phoneLabel.text = institution.phone != "" ? institution.phone : "-"
            }
    }
    
    func setupTableViewHeight() {
        var height : CGFloat = 55
        
        if self.items.count > 0 {
            height =  CGFloat(55 * self.items.count)
        }
        self.tableViewHeight.constant = height
        self.view.layoutIfNeeded()
        
        self.tableView.reloadData()
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
    
    // MARK: - Action methods
    @IBAction func collapseDetails(_ sender: Any) {
        self.institutionUser = nil
        
        let mapViewController = parent as! MapViewController
        mapViewController.containerHeightConstraint.constant = 0;
        
        UIView.animate(withDuration: 0.5, animations: {
            mapViewController.view.layoutIfNeeded()
        })
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows = 1
        
        if items.count > 0 {
            numberOfRows = items.count
        }
        
        return numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailOrderCell", for: indexPath) as! MyItemsTableViewCell
    
        if items.count > 0 {
            let orderItem = items[indexPath.row]
            
            cell.imageViewIcon.image = UIImage(named: imageNameForItem(orderItem.name))
            cell.labelTitle?.text = orderItem.name
            let publishDate = Helper.dateFrom(string: orderItem.publishDate, format: "dd/MM/yyyy HH:mm")
            cell.labelSubtitle.text = Helper.periodBetween(date1: publishDate, date2: Date())
            
            return cell
        } else {
            cell.imageViewIcon.image = UIImage(named: imageNameForItem(""))
            cell.labelTitle?.text = "Não existem pedidos cadastrados."
            cell.labelSubtitle?.text = ""
            
            return cell
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
