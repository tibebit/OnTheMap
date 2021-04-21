//
//  StudentInformation.swift
//  OnTheMap2
//
//  Created by Fabio Tiberio on 19/04/21.
//

import Foundation

struct StudentInformation: Codable {
    var objectId: String?
    var uniqueKey: String?
    var firstName: String?
    var lastName: String?
    var mapString: String?
    var mediaURL: String?
    var latitude: Double?
    var longitude: Double?
    var createdAt: String?
    var updatedAt: String?
}
