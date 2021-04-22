//
//  File.swift
//  OnTheMap2
//
//  Created by Fabio Tiberio on 19/04/21.
//

import Foundation

class UdacityClient {
    static let baseURL = "https://onthemap-api.udacity.com/v1"
    static let session = "/session"
    static let users = "/users"
    
    private struct Auth {
        static var sessionId = ""
    }
    enum Endpoints {
        case signupPage
        case getSessionId
        case getUserData(key: String)
        case deleteSessionId
        
        var url: URL {
            return URL(string: stringValue)!
        }
        var stringValue: String {
            switch self {
            case .getSessionId:
                return UdacityClient.baseURL + UdacityClient.session
            case .getUserData(let key):
                return UdacityClient.baseURL + UdacityClient.users + "/\(key)"
            case .deleteSessionId:
                return UdacityClient.baseURL + UdacityClient.session
            case .signupPage:
                return "https://auth.udacity.com/sign-up"
            }
        }
    }
    
    //MARK: GETting public user data
    // Get data about the logged in user
    class func getUserData(key: String, completion: @escaping (User?, Error?) -> Void) {
        //TODO: Implement this logic
        let task = URLSession.shared.dataTask(with: UdacityClient.Endpoints.getUserData(key: key).url) { data, response, error in
            if let error = error {
                //handle error
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            guard var data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let range = 5..<data.count
            data = data.subdata(in: range)
            let decoder = JSONDecoder()
            do {
                let user = try decoder.decode(User.self, from: data)
                completion(user, nil)
            } catch {
                do {
                    let errorResponse = try decoder.decode(UdacityResponse.self, from: data)
                    DispatchQueue.main.async {
                        completion(nil, errorResponse)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
        }
        task.resume()
    }
    //MARK: POSTing a session
    // if the request succed the user's Udacity accound id is passed to the completion handler
    class func loginRequest(username: String, password: String, completion: @escaping (String? ,Error?)->Void) {
        let loginRequest = LoginRequest(udacity: Udacity(username: username, password: password))
        var request = URLRequest(url: UdacityClient.Endpoints.getSessionId.url)
        
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            let json = try JSONEncoder().encode(loginRequest)
            request.httpBody = json
        } catch {
            DispatchQueue.main.async {
                completion(nil, error)
            }
        }
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            guard var data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let range = 5..<data.count
            data = data.subdata(in: range)
            let decoder = JSONDecoder()
            do {
                let loginResponse = try decoder.decode(LoginResponse.self, from: data)
                Auth.sessionId = loginResponse.session.id
                DispatchQueue.main.async {
                    completion(loginResponse.account.key, nil)
                }
            } catch {
                do {
                    let errorResponse = try decoder.decode(UdacityResponse.self, from: data)
                    DispatchQueue.main.async {
                        completion(nil, errorResponse)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
            
        }
        task.resume()
    }
    //MARK: DELETEing a session
    class func logoutRequest(completion: @escaping (Bool, Error?)->Void) {
        var request = URLRequest(url: UdacityClient.Endpoints.deleteSessionId.url)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" {
                xsrfCookie = cookie
            }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request) {
            data, response, error in
            if error != nil {
                //Handle error...
                DispatchQueue.main.async {
                    completion(false, error)
                }
                return
            }
            //let range = 5..<data!.count
            //let newData = data?.subdata(in: range)
            DispatchQueue.main.async {
                completion(true, error)
            }
        }
        task.resume()
    }
}
