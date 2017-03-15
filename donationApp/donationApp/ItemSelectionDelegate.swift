//
//  ItemSelectionDelegate.swift
//  donationApp
//
//  Created by Letícia Fernandes on 11/03/17.
//  Copyright © 2017 PUC. All rights reserved.
//

import Foundation
import UIKit

public protocol ItemSelectionDelegate : class {
    func didPressSaveWithSelectItem(_ item: String)
}
