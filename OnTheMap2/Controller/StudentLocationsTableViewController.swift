//
//  StudentLocationsTableViewController.swift
//  OnTheMap2
//
//  Created by Fabio Tiberio on 19/04/21.
//

import UIKit

class StudentLocationsTableViewController: UIViewController {
    //MARK: Outlets
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    //MARK: Lifecycle
    override func viewDidLoad() {
        if StudentInformationModel.locations.isEmpty {
            loading(activityIndicator: loadingIndicator, isLoading: true)
            locationsRequest()
        }
    }
    //clear shared instance's data
    deinit {
        StudentInformationModel.locations.removeAll()
        StudentInformationModel.studentLocation = StudentInformation()
    }
    //MARK: API Requests
    // download the 100 most recent locations posted by students
    func locationsRequest() {
        ParseClient.getStudentLocations(completion: handleStudentLocationsResponse(studentLocations:error:))
    }
    //MARK: Responses Handling
    func handleStudentLocationsResponse(studentLocations: [StudentInformation], error: Error?) {
        if studentLocations.count > 0 {
            StudentInformationModel.locations = studentLocations
            DispatchQueue.main.async {
                self.tableview.reloadData()
            }
        } else {
            showAlert(message: error?.localizedDescription.uppercased())
        }
        DispatchQueue.main.async {
            self.loading(activityIndicator: self.loadingIndicator, isLoading: false)
        }
    }
    func handleUserDataResponse(user: User?, error: Error?) {
        if let user = user {
            StudentInformationModel.studentLocation.firstName = user.firstName
            StudentInformationModel.studentLocation.lastName = user.lastName
        }
    }
    
    //MARK: Actions
    @IBAction func refreshButtonPressed(_ sender: Any) {
        loading(activityIndicator: loadingIndicator, isLoading: true)
        StudentInformationModel.locations.removeAll()
        tableview.reloadData()
        locationsRequest()
    }
    @IBAction func logoutButtonPressed(_ sender: Any) {
        UdacityClient.logoutRequest { (success, error) in
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    @IBAction func addLocationButtonPressed(_ sender: Any) {
        let informationPostingVC = self.storyboard?.instantiateViewController(withIdentifier: "addLocationVC") as! InformationPostingViewController
        ParseClient.checkStudentLocation(uniqueKey: StudentInformationModel.studentLocation.uniqueKey!) { (studentLocation, error) in
            if let studentLocation = studentLocation, studentLocation.objectId != nil {
                let actions = [UIAlertAction(title: "Overwrite", style: .default, handler: { (_) in
                    StudentInformationModel.studentLocation = studentLocation
                    informationPostingVC.action = .update
                    self.present(informationPostingVC, animated: true)
                }), UIAlertAction(title: "Cancel", style: .default)]
                DispatchQueue.main.async {
                    self.showAlert(title: "Note", message: "YOU HAVE ALREADAY POSTED A STUDENT LOCATION. WOULD YOU LIKE TO OVERWRITE YOUR CURRENT LOCATION?", actions)
                }
            } else {
                informationPostingVC.action = .create
                self.present(informationPostingVC, animated: true)
            }
        }
    }
}
//MARK: Table View Delegate Table View Data Source
extension StudentLocationsTableViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentInformationModel.locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell")!
        let information = StudentInformationModel.locations[indexPath.row]
        cell.textLabel?.text = (information.firstName ?? "Pablo" ) + " " + (information.lastName ?? "Star")
        cell.detailTextLabel?.text = information.mediaURL
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let url = URL(string: StudentInformationModel.locations[indexPath.row].mediaURL ?? "")!
        tableview.deselectRow(at: [indexPath.row], animated: true)
        open(urlToOpen: url)
    }
}
