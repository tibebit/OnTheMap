//
//  ViewController.swift
//  OnTheMap2
//
//  Created by Fabio Tiberio on 19/04/21.
//

import UIKit

class LoginViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var emailTextField: OTMTextField!
    @IBOutlet weak var passwordTextField: OTMTextField!
    @IBOutlet weak var loggingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loginButton: OTMButton!
    @IBOutlet weak var signupButton: UIButton!
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.text = ""
        passwordTextField.text = ""
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    //MARK: Actions
    @IBAction func loginButtonPressed(_ sender: Any) {
        if !emailTextField.text!.isEmpty && !passwordTextField.text!.isEmpty {
            //show activity indicator
            loading(activityIndicator: loggingIndicator, controls: [emailTextField, passwordTextField, loginButton, signupButton], isLoading: true)
            UdacityClient.loginRequest(username: emailTextField.text!, password: passwordTextField.text!, completion: handleLoginResponse(key:error:))
        } else {
            showAlert(message: "YOU NEED TO FILL IN EACH TEXT FIELD")
        }
    }
    @IBAction func signupButtonPressed() {
        open(urlToOpen: UdacityClient.Endpoints.signupPage.url)
    }
    //MARK: API Responses Handling
    func handleLoginResponse(key: String?, error: Error?) {
        //hide activity indicator
        loading(activityIndicator: loggingIndicator, controls: [emailTextField, passwordTextField, loginButton, signupButton], isLoading: false)
        if let key = key {
            StudentInformationModel.studentLocation.uniqueKey = key
        let tabVC = storyboard?.instantiateViewController(withIdentifier: "tabVC") as! UITabBarController
            navigationController?.pushViewController(tabVC, animated: true)
        } else {
            showAlert(message: error?.localizedDescription.uppercased())
        }
    }
}
