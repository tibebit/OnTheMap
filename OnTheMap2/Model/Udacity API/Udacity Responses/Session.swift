//
//  Session.swift
//  OnTheMap2
//
//  Created by Fabio Tiberio on 19/04/21.
//

import Foundation

struct Session: Codable {
    let id: String
    let expiration: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case expiration
    }
}
