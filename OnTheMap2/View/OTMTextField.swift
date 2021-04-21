//
//  OTMTextField.swift
//  OnTheMap2
//
//  Created by Fabio Tiberio on 19/04/21.
//
import UIKit

class OTMTextField: UITextField {
    struct Constants {
           static let sidePadding: CGFloat = 10
           static let topPadding: CGFloat = 8
       }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
           return CGRect(
               x: bounds.origin.x + Constants.sidePadding,
               y: bounds.origin.y + Constants.topPadding,
               width: bounds.size.width - Constants.sidePadding * 2,
               height: bounds.size.height - Constants.topPadding * 2
           )
       }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
           return self.textRect(forBounds: bounds)
       }
}
