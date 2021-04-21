//
//  ParseResponse.swift
//  OnTheMap2
//
//  Created by Fabio Tiberio on 19/04/21.
//

import Foundation

struct ParseResponse: Codable {
    let code: Int
    let error: String
}
extension ParseResponse: LocalizedError {
    var errorDescription: String? {
        return error
    }
}

