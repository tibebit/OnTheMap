//
//  LoginButton.swift
//  OnTheMap2
//
//  Created by Fabio Tiberio on 19/04/21.
//

import UIKit

class OTMButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 5
        tintColor = UIColor.white
        backgroundColor = UIColor(named: "Button")
        contentEdgeInsets = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
    }
}
