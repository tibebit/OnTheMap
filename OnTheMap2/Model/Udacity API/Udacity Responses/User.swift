//
//  File.swift
//  OnTheMap2
//
//  Created by Fabio Tiberio on 19/04/21.
//

import Foundation

struct User: Codable {
    let lastName: String
    let firstName: String
    
    enum CodingKeys: String, CodingKey {
        case lastName = "last_name"
        case firstName = "first_name"
    }
}
