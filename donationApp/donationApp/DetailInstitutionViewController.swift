//
//  DetailInstitutionViewController.swift
//  donationApp
//
//  Created by Letícia Fernandes on 13/03/17.
//  Copyright © 2017 PUC. All rights reserved.
//

/*
import UIKit
import MapKit

class DetailInstitutionViewController: UIViewController {

    var institution : Institution = Institution(name: "", info: "", email: "", contact: "", phone: "", bank: "", agency: "", accountNumber: "", address: "", district: "", city: "", state: "", zipCode: "", group: "", coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0))
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var groupLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var contactLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Popup
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        self.showAnimate()
        
        self.nameLabel.text = self.institution.name
        self.groupLabel.text = self.institution.group
        self.emailLabel.text = self.institution.email
        self.addressLabel.text =  institution.address + " " + institution.district + ", " + institution.city + " - " + institution.state + ". CEP: " + self.institution.zipCode
        self.contactLabel.text = self.institution.contact
        self.phoneLabel.text = self.institution.phone
    }
    
    
    @IBAction func close(_ sender: Any) {
        self.removeAnimate()
    }
    
    // MARK: - Popup
    func showAnimate()
    {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0;
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        });
    }
    
    func removeAnimate()
    {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0;
        }, completion:{(finished : Bool)  in
            if (finished)
            {
                self.view.removeFromSuperview()
            }
        });
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
 */
