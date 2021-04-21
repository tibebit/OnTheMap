//
//  UdacityResponse.swift
//  OnTheMap2
//
//  Created by Fabio Tiberio on 19/04/21.
//

import Foundation

struct UdacityResponse:Codable {
    let status: Int
    let error: String
}
extension UdacityResponse: LocalizedError {
    var errorDescription: String? {
        return error
    }
}
