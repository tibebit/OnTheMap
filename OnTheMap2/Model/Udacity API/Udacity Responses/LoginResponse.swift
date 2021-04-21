//
//  LoginResponse.swift
//  OnTheMap2
//
//  Created by Fabio Tiberio on 19/04/21.
//

import Foundation

struct LoginResponse:Codable {
    let account: Account
    let session: Session
}
