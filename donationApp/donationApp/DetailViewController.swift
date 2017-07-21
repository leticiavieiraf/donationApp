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
    
    // variables
    var institution = Institution()
    var institutionUser = InstitutionUser()
    var items: [OrderItem] = []
    
    // firebase refs
    let refOrderItems = Database.database().reference(withPath: "order-items")
    let refInstitutionsUsers = Database.database().reference(withPath: "institution-users")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Auth.auth().currentUser == nil {
            print("Facebook: User IS NOT logged in!")
            print("Firebase: User IS NOT logged in!")
            
            // Redireciona para tela de login
            let loginNav = UIStoryboard(name: "Main", bundle:nil).instantiateInitialViewController()
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = loginNav
            
        } else {

            self.nameLabel.text = self.institution.name
            self.emailLabel.text = self.institution.email
            self.addressLabel.text = self.institution.address + ", " + self.institution.district + ", " + self.institution.city + " - " + self.institution.state + ". Cep: " + self.institution.zipCode
            self.infoLabel.text = self.institution.group
            self.phoneLabel.text = self.institution.phone
            
            getInstitutionUser(institution)
        }
    }

    func getInstitutionUser(_ institution: Institution) {
        
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.show()
        
        refInstitutionsUsers.observe(.value, with: { snapshot in
            
            for item in snapshot.children {
                let user = InstitutionUser(snapshot: item as! DataSnapshot)
                 
                if self.institution.email == user.email  {
                    self.institutionUser = user
                    self.loadOrdersFrom(self.institutionUser.uid)
                }
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
            self.tableView.reloadData()
            
            SVProgressHUD.dismiss()
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailOrderCell", for: indexPath) as! MyItemsTableViewCell
        let orderItem = items[indexPath.row]
        
        cell.labelTitle?.text = orderItem.name
        cell.labelSubtitle?.text = "Publicado em " + orderItem.publishDate
        
        return cell
    }
}
