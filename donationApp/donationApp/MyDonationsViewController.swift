//
//  MyDonationsViewController.swift
//  donationApp
//
//  Created by Natalia Sheila Cardoso de Siqueira on 11/03/17.
//  Copyright © 2017 PUC. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class MyDonationsViewController: UIViewController, UITableViewDataSource, ItemSelectionDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var items : [DonationItem] = []
    var donatorUser : DonatorUser!
    let ref = FIRDatabase.database().reference(withPath: "donation-items")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBarController?.title = "Minhas doações"
        let addButton = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(showNewDonationPopUp))
        self.tabBarController?.navigationItem.rightBarButtonItem = addButton
        
        
        if FIRAuth.auth()?.currentUser == nil {
            print("Firebase: User IS NOT logged in!")
            //Redirecionar para Tela de login!
            return
            
        } else {
            donatorUser = DonatorUser(uid: (FIRAuth.auth()?.currentUser?.uid)!,
                                      email: (FIRAuth.auth()?.currentUser?.email)!,
                                      name: (FIRAuth.auth()?.currentUser?.displayName)!,
                                      photoUrl: (FIRAuth.auth()?.currentUser?.photoURL?.absoluteString)!)
        }
    }
    
    func showNewDonationPopUp() {
     
        let newDonationVC = UIStoryboard(name: "Donators", bundle:nil).instantiateViewController(withIdentifier: "sbPopUpID") as! NewDonationViewController
        newDonationVC.delegate = self
        self.addChildViewController(newDonationVC)
        newDonationVC.view.frame = self.view.frame
        self.view.addSubview(newDonationVC.view)
        newDonationVC.didMove(toParentViewController: self)
    }
    
    func didPressSaveWithSelectItem(_ item: String) {
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
        let dateStr = formatter.string(from: date)
        
  
        let donationItem = DonationItem(name: item, donator: donatorUser, publishDate: dateStr)
        let groceryItemRef = self.ref.child(item.lowercased())
        groceryItemRef.setValue(donationItem.toAnyObject())

        //items.append(donationItem)
        tableView.reloadData()
    }
    
    // MARK: UITableViewDataSource
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return items.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "donationCell", for: indexPath)
        let donationItem = items[indexPath.row]
        
        cell.textLabel?.text = donationItem.name
        cell.detailTextLabel?.text = "Publicado em " + donationItem.publishDate
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
      
        if editingStyle == .delete {
            items.remove(at: indexPath.row)
            tableView.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
