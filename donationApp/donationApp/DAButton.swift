//
//  DAButton.swift
//  donationApp
//
//  Created by Letícia Fernandes on 13/03/17.
//  Copyright © 2017 PUC. All rights reserved.
//

import UIKit

@IBDesignable
class DAButton: UIButton {
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 1.0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 1.0 {
        didSet {
            layer.cornerRadius = cornerRadius
            clipsToBounds = true
        }
    }
    
    //MARK: Initializers
    
    override init(frame : CGRect) {
        super.init(frame : frame)
        setup()
        configure()
    }
    
    convenience init() {
        self.init(frame:CGRect.zero)
        setup()
        configure()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
        configure()
    }
    
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        setup()
        configure()
    }
    
    override public func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setup()
        configure()
    }
    
    func setup() {
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 1.0
        layer.cornerRadius = 1.0
    }
    
    func configure() {
        layer.borderColor = borderColor.cgColor
        layer.borderWidth = borderWidth
        layer.cornerRadius = cornerRadius
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
    }
}
