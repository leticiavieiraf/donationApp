//
//  ItemsTableViewCell.swift
//  donationApp
//
//  Created by Leticia Vieira Fernandes on 15/04/17.
//  Copyright © 2017 PUC. All rights reserved.
//

import UIKit

class ItemsTableViewCell: UITableViewCell {


    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var publishDateLabel: UILabel!
    
    func loadImageWith(_ urlString: String) {
        let url: URL = URL(string: urlString)!
        let defaultImage = UIImage(named: "ico-default")
        self.profileImageView.kf.setImage(with: url, placeholder: defaultImage);
    }
    
//    func loadImageWith(_ urlString: String) throws {
//        
//        let url: URL = URL(string: urlString)!
//
//        DispatchQueue.global().async {
//            let data = try? Data(contentsOf: url)
//
//            DispatchQueue.main.async {
//                self.profileImage.image = UIImage(data: data!)
//            }
//        }
//    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
