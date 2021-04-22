//
//  StudentLocationsMapViewController.swift
//  OnTheMap2
//
//  Created by Fabio Tiberio on 19/04/21.
//

import UIKit
import MapKit

class StudentLocationsMapViewController: UIViewController {
    //MARK: Outlets
    @IBOutlet weak var mapview: MKMapView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        if StudentInformationModel.locations.isEmpty {
            //show activity indicator
            loading(activityIndicator: loadingIndicator, isLoading: true)
            mapview.removeAnnotations(mapview.annotations)
            
            locationsRequest()
        }
        // get logged in user first name and last name
        UdacityClient.getUserData(key: StudentInformationModel.studentLocation.uniqueKey ?? "", completion: handleUserDataResponse(user:error:))
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
    //MARK: API Responses Handling
    //store user first name and last name if any
    func handleUserDataResponse(user: User?, error: Error?) {
        if let user = user {
            StudentInformationModel.studentLocation.firstName = user.firstName
            StudentInformationModel.studentLocation.lastName = user.lastName
        }
    }
    // create a point annotations from locations posted by other students
    func handleStudentLocationsResponse(studentLocations: [StudentInformation], error: Error?) {
        if studentLocations.count > 0 {
            StudentInformationModel.locations = studentLocations
            var annotations = [MKPointAnnotation]()
            
            for information in StudentInformationModel.locations {
                annotations.append(createAnnotation(annotation: MKPointAnnotation(), information: information))
            }
            DispatchQueue.main.async {
                self.mapview.addAnnotations(annotations)
            }
        } else {
            showAlert(message: error?.localizedDescription.uppercased())
        }
        DispatchQueue.main.async {
            //hide activity indicator
            self.loading(activityIndicator: self.loadingIndicator, isLoading: false)
        }
    }
    //MARK: Annotation
    func createAnnotation(annotation:MKPointAnnotation,information: StudentInformation) -> MKPointAnnotation {
        annotation.title = (information.firstName ?? "Pablo" ) + " " + (information.lastName ?? "Star")
        annotation.subtitle = information.mediaURL
        annotation.coordinate = CLLocationCoordinate2D(latitude: information.latitude!, longitude: information.longitude!)
        return annotation
    }
    //MARK: Actions
    @IBAction func refreshButtonPressed(_ sender: Any) {
        //show activity indicator
        loading(activityIndicator: loadingIndicator, isLoading: true)
        StudentInformationModel.locations.removeAll()
        mapview.removeAnnotations(mapview.annotations)
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
//MARK: Map View Delegate
extension StudentLocationsMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.pinTintColor = .red
            //Can display additional info in a bubble
            pinView!.canShowCallout = true
            pinView!.rightCalloutAccessoryView = UIButton(type: UIButton.ButtonType.detailDisclosure)
        } else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let url = URL(string: ((view.annotation?.subtitle) ?? "")!)!
            open(urlToOpen: url)
        }
    }
}
