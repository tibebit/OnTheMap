//
//  InformationPostingViewController.swift
//  OnTheMap2
//
//  Created by Fabio Tiberio on 19/04/21.
//

import UIKit
import MapKit

class InformationPostingViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var mapview: MKMapView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var addressTextField: OTMTextField!
    @IBOutlet weak var mediaURLTextField: OTMTextField!
    @IBOutlet weak var finishButton: OTMButton!
    @IBOutlet weak var findLocationButton: OTMButton!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    //MARK: Properties
    var annotation: MKPointAnnotation!
    var action: Action!
    //MARK: Enum
    enum Action {
        case create
        case update
    }
    
    //MARK: Lifecyle
    override func viewDidLoad() {
        annotation = MKPointAnnotation()
        mediaURLTextField.text = ""
        addressTextField.text = ""
        mediaURLTextField.delegate = self
        addressTextField.delegate = self
    }
    //MARK: UI Functions
    func toggleVisibility(components: [UIView], isHidden: Bool) {
        for component in components {
            component.isHidden = isHidden
        }
    }
    //MARK: Responses Handling
    // if geocoding succed, this function hides the form and show a mapview with a pin which represents the coordinates for the address inserted by the user. Otherwise show an alert
    func handleFindLocationResponse(coordinate: CLLocationCoordinate2D?, error: Error?) {
        DispatchQueue.main.async {
            // hide activity indicator
            self.loading(activityIndicator: self.loadingIndicator, controls: [self.addressTextField, self.mediaURLTextField, self.findLocationButton], isLoading: false)
        }
        if let coordinate = coordinate {
            StudentInformationModel.studentLocation.latitude = coordinate.latitude
            StudentInformationModel.studentLocation.longitude = coordinate.longitude
            // hide the form
            self.toggleVisibility(components: [self.imageView, self.mediaURLTextField, self.addressTextField, self.findLocationButton], isHidden: true)
            self.toggleVisibility(components: [self.finishButton, self.mapview], isHidden: false)
            self.annotation.title = self.addressTextField.text
            self.annotation.coordinate = coordinate
            self.mapview.addAnnotation(self.annotation)
            //set the region of the map to the the location where the pin points
            self.mapview.region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        } else {
            self.showAlert(message: error?.localizedDescription.uppercased())
        }
    }
    // if the location was posted the view is dismissed. Otherwise show an alert
    func handlePostLocationResponse(studentInformation: StudentInformation?, error: Error?) {
        if let studentInformation = studentInformation {
            StudentInformationModel.studentLocation.objectId = studentInformation.objectId
            StudentInformationModel.studentLocation.createdAt = studentInformation.createdAt
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
        } else {
            showAlert(message: error?.localizedDescription.uppercased())
        }
    }
    // if the location was updated the view is dismissed. Otherwise show an alert
    func handleUpdateLocationResponse(studentInformation: StudentInformation?, error: Error?) {
        if let studentInformation = studentInformation {
            StudentInformationModel.studentLocation.updatedAt = studentInformation.updatedAt
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
        } else {
            showAlert(message: error?.localizedDescription.uppercased())
        }
    }
    //MARK: Actions
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    // try to geocode the address string given by the user
    @IBAction func findLocationButtonPressed(_ sender: Any) {
        // show activity indicator
        loading(activityIndicator: loadingIndicator, controls: [addressTextField, mediaURLTextField, findLocationButton], isLoading: true)
        if !mediaURLTextField.text!.isEmpty && !addressTextField.text!.isEmpty {
            ParseClient.findLocation(addressString: addressTextField.text!, completion: handleFindLocationResponse(coordinate:error:))
        } else {
            showAlert(message: "YOU NEED TO FILL IN EACH TEXT FIELD")
        }
    }
    // Post the user location if the action is .created
    // Update the user location if the action is .update
    @IBAction func finishButtonPressed(_ sender: Any) {
        StudentInformationModel.studentLocation.mediaURL = mediaURLTextField.text
        StudentInformationModel.studentLocation.mapString = addressTextField.text
        if case action = Action.create {
            ParseClient.postStudentLocation(studentInformation: StudentInformationModel.studentLocation, completion: handlePostLocationResponse(studentInformation:error:))
        } else {
            ParseClient.updateStudentLocation(studentInformation: StudentInformationModel.studentLocation, completion: handleUpdateLocationResponse(studentInformation:error:))
        }
    }
}
//MARK: Map View Delegate
extension InformationPostingViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.pinTintColor = .red
            pinView!.canShowCallout = true
        } else {
            pinView!.annotation = annotation
        }
        return pinView
    }
}


