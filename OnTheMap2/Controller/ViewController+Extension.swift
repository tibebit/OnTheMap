//
//  ViewController+Extension.swift
//  OnTheMap2
//
//  Created by Fabio Tiberio on 20/04/21.
//

import UIKit

extension UIViewController {
    //MARK: UI Functions
    //Customizable alert with default parameters
    func showAlert(title: String? = "Error" ,message: String? = "Something went wrong", _ actions: [UIAlertAction]? = nil) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if let actions = actions {
            for action in actions {
                alertVC.addAction(action)
            }
        } else {
            alertVC.addAction(UIAlertAction(title: "OK", style: .default))
        }
        DispatchQueue.main.async {
            self.present(alertVC, animated: true)
        }
    }
    
    //MARK: Utility
    func open(urlToOpen url: URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    // show/hide the activity indicator vie
    func loading(activityIndicator: UIActivityIndicatorView ,controls: [UIControl] = [] ,isLoading: Bool) {
        isLoading ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
        if !controls.isEmpty {
            setUIState(controls: controls, enabled: !isLoading)
        }
    }
    //disable/enable all the controls passed
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
