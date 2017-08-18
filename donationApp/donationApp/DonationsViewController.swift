//
//  DonationsViewController.swift
//  donationApp
//
//  Created by Letícia Fernandes on 14/04/17.
//  Copyright © 2017 PUC. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import SVProgressHUD
import AVFoundation

class DonationsViewController: UIViewController, UITableViewDataSource {
    
    // outlets
    @IBOutlet weak var tableView: UITableView!
    
    // variables
    var allDonations: [DonationItem] = []
    var sweaters: [DonationItem] = []
    var food: [DonationItem] = []
    var shoes: [DonationItem] = []
    var hygieneProducts: [DonationItem] = []
    var clothes: [DonationItem] = []
    var sections: [String] = []
    
    // firebase variables
    let refDonationItems = Database.database().reference(withPath: "donation-items")

    // MARK: - Life Cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupTabBarController()
        
        if userLoggedIn() {
            loadDonations()
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
        self.tabBarController?.title = "Doações"
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        self.tabBarController?.navigationItem.leftBarButtonItem = nil
        self.tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - Firebase methods
    func loadDonations() {
        
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.show()
        
        refDonationItems.child("users-uid").observe(.value, with: { (snapshot) in
            var count = 0
            var userIdKeys: [String] = []
            var donations: [DonationItem] = []
            
            for item in snapshot.children.allObjects {
                let userId = item as! DataSnapshot
                userIdKeys.append(String(userId.key))
            }
            
            for userIdKey in userIdKeys {
                self.refDonationItems.child("users-uid").child(userIdKey.lowercased()).observe(.value, with: { (snapshot) in
                    
                    for item in snapshot.children.allObjects {
                        let donationItem = DonationItem(snapshot: item as! DataSnapshot)
                        donations.append(donationItem)
                    }
                    
                    count += 1
                    if count == userIdKeys.count {
                        self.allDonations = donations
                        self.setupDataSource()
                        
                        SVProgressHUD.dismiss()
                    }
                })
            }
        })
    }
    
    // MARK: - Setup DataSource methods
    func setupDataSource() {
        resetDataSource()
        
        sections =  [Constants.kSweaters,
                     Constants.kFood,
                     Constants.kShoes,
                     Constants.kHygieneProducts,
                     Constants.kClothes]
        
        for donation in allDonations {
            switch donation.name {
            case Constants.kSweaters:
                sweaters.append(donation)
            case Constants.kFood:
                food.append(donation)
            case Constants.kShoes:
                shoes.append(donation)
            case Constants.kHygieneProducts:
                hygieneProducts.append(donation)
            case Constants.kClothes:
                clothes.append(donation)
            default:
                allDonations.append(donation)
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
    
    // MARK: Setup TableView methods
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
            return allDonations.count
        }
    }
    
    func getDonationForRowAtIndexPath(_ indexPath: IndexPath) -> DonationItem {
        let sectionTitle = sections[indexPath.section]
        var donationItem: DonationItem
        
        switch sectionTitle {
        case Constants.kSweaters:
            donationItem = sweaters[indexPath.row]
        case Constants.kFood:
            donationItem = food[indexPath.row]
        case Constants.kShoes:
            donationItem = shoes[indexPath.row]
        case Constants.kHygieneProducts:
            donationItem = hygieneProducts[indexPath.row]
        case Constants.kClothes:
            donationItem = clothes[indexPath.row]
        default:
            donationItem = allDonations[indexPath.row]
        }
        return donationItem
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "donationPostCell", for: indexPath) as! ItemsTableViewCell
        let donationItem = getDonationForRowAtIndexPath(indexPath)
        
        cell.itemNameLabel.text = "Quero doar " + donationItem.name.lowercased() + "!"
        cell.userNameLabel.text = donationItem.addedByUser
        cell.userEmailLabel.text = donationItem.userEmail
        let publishDate = Helper.dateFrom(string: donationItem.publishDate, format: "dd/MM/yyyy HH:mm")
        cell.publishDateLabel.text = Helper.periodBetween(date1: publishDate, date2: Date())
        cell.loadImageWith(donationItem.userPhotoUrl)
        
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
