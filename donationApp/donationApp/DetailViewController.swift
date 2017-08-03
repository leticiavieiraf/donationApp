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
    
    //constraints
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    // variables
    var institution = Institution()
    var institutionUser : InstitutionUser?
    var items: [OrderItem] = []
    
    // firebase refs
    let refOrderItems = Database.database().reference(withPath: "order-items")
    let refInstitutionsUsers = Database.database().reference(withPath: "institution-users")
    
    // MARK: Life Cycle methods
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
    
    // MARK: Data Source methods
    func loadData() {
        if let institutionUser = self.institutionUser {
            setupDetailsBox(institutionUser)
            loadOrdersFrom(institutionUser.uid)
        } else {
            getInstitutionUserAndLoadOrders()
        }
    }

    // MARK: Firebase methods
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
                self.setupDetailsBox(foundUser)
                self.loadOrdersFrom(foundUser.uid)
            } else {
                SVProgressHUD.dismiss()
            }
        })
    }
    
    func loadOrdersFrom(_ userUID: String) {
        
        refOrderItems.child("users-uid").child(userUID.lowercased()).observe(.value, with: { (snapshot) in
            
            var userItems: [OrderItem] = []
            
            for item in snapshot.children.allObjects {
                let orderItem = OrderItem(snapshot: item as! DataSnapshot)
                userItems.append(orderItem)
            }
            
            self.items = userItems
            self.setupTableView()
            
            SVProgressHUD.dismiss()
        })
    }
    
    // MARK: Setup methods
    func setupDetailsBox(_ institution: InstitutionUser) {
        self.nameLabel.text = institution.name
        self.emailLabel.text = institution.email
        self.addressLabel.text = institution.address + ", " + institution.district + ", " + institution.city + " - " + institution.state + ". Cep: " + institution.zipCode
        self.infoLabel.text = institution.group
        self.phoneLabel.text = institution.phone
    }
    
    func setupTableView() {
        self.tableViewHeight.constant = CGFloat(55 * self.items.count)
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
        case Constants.kHygiene:
            return "higiene"
        case Constants.kClothes:
            return "roupas"
        default:
            return "higiene"
        }
    }
    
    // MARK: Action methods
    @IBAction func collapseDetails(_ sender: Any) {
        let mapViewController = parent as! MapViewController
        mapViewController.containerHeightConstraint.constant = 0;
        
        UIView.animate(withDuration: 0.5, animations: {
            mapViewController.view.layoutIfNeeded()
        })
    }
    
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailOrderCell", for: indexPath) as! MyItemsTableViewCell
        let orderItem = items[indexPath.row]
        
        cell.imageViewIcon.image = UIImage(named: imageNameForItem(orderItem.name))
        cell.labelTitle?.text = orderItem.name
        cell.labelSubtitle?.text = "Publicado em " + orderItem.publishDate
        
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
