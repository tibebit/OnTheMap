//
//  StudentInformationModel.swift
//  OnTheMap2
//
//  Created by Fabio Tiberio on 19/04/21.
//

import Foundation

class StudentInformationModel {
    // locations loaded from the Parse API after a GET request
    static var locations = [StudentInformation]()
    // the information about the student that is using the app
    static var studentLocation = StudentInformation()
}
