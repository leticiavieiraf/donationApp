//
//  MyItemsTableViewCell.swift
//  donationApp
//
//  Created by Letícia on 20/07/17.
//  Copyright © 2017 PUC. All rights reserved.
//

import UIKit

class MyItemsTableViewCell: UITableViewCell {

    @IBOutlet weak var imageViewIcon: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelSubtitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
