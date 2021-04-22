//
//  ViewController+Extension.swift
//  OnTheMap2
//
//  Created by Fabio Tiberio on 20/04/21.
//

import UIKit

extension UIViewController {
    //MARK: UI Functions
    func showAlert(title: String ,message: String? = "Something went wrong", _ actions: [UIAlertAction]? = nil) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if let actions = actions {
            for action in actions {
                alertVC.addAction(action)
            }
        } else {
            alertVC.addAction(UIAlertAction(title: "OK", style: .default))
        }
        self.present(alertVC, animated: true)
    }
    
    //MARK: Utility
    func open(urlToOpen url: URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    func loading(activityIndicator: UIActivityIndicatorView ,controls: [UIControl]? ,isLoading: Bool) {
        if isLoading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
        if let controls = controls {
            setUIState(controls: controls, enabled: !isLoading)
        }
    }
    func setUIState(controls: [UIControl], enabled: Bool) {
        for control in controls {
            control.isEnabled = enabled
        }
    }
}
extension UIViewController: UITextFieldDelegate {
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.becomeFirstResponder()
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
