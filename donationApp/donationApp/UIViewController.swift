//
//  UIViewController.swift
//  donationApp
//
//  Created by Letícia on 17/08/17.
//  Copyright © 2017 PUC. All rights reserved.
//

import UIKit

typealias HandlerBlock = () -> Void

extension UIViewController {
    
    func showAlert(title: String, message: String, handler: HandlerBlock?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            if let block = handler {
                block()
            }
        })
        
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}
