//
//  ParseClient.swift
//  OnTheMap2
//
//  Created by Fabio Tiberio on 19/04/21.
//
import Foundation
import CoreLocation

class ParseClient {
    static let baseURL = "https://onthemap-api.udacity.com/v1/StudentLocation"
    
    enum Endpoints {
        case getStudentLocations(query: String)
        case postStudentLocation
        case updateLocation(objectId: String)
        
        var url: URL {
            return URL(string: stringValue)!
        }
        // Review this step
        var stringValue: String {
            switch self {
            case .getStudentLocations(let query):
                return ParseClient.baseURL + query
            case .postStudentLocation:
                return ParseClient.baseURL
            case .updateLocation(let objectId):
                return ParseClient.baseURL + "/\(objectId)"
            }
        }
    }
    //MARK: Generics functions
    class func taskForPRequest<RequestType: Encodable, ResponseType: Decodable>(url: URL, body: RequestType, httpMethod: String, response: ResponseType.Type, completion: @escaping (ResponseType?, Error?)->Void) {
        var request = URLRequest(url: url)
        
        request.httpMethod = httpMethod
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            let requestObject = try JSONEncoder().encode(body)
            request.httpBody = requestObject
        } catch {
            completion(nil, error)
        }
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                //Handle error
                return
            }
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                do {
                    let errorResponse = try decoder.decode(ParseResponse.self, from: data)
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
    class func taskForGETRequest<ResponseType: Decodable>(url: URL, response: ResponseType.Type, completionHandler: @escaping (ResponseType?, Error?)->Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completionHandler(responseObject, nil)
                }
            } catch {
                do {
                    let errorResponse = try decoder.decode(ParseResponse.self, from: data)
                    DispatchQueue.main.async {
                        completionHandler(nil, errorResponse)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completionHandler(nil, error)
                    }
                }
            }
        }
        task.resume()
    }
    //MARK: GETting Locations
    //Get the last 100 student locations
    class func getStudentLocations(completion: @escaping ([StudentInformation], Error?) -> Void) {
        var components = URLComponents()
        components.queryItems = [URLQueryItem(name: "?limit", value: "100"), URLQueryItem(name: "order", value: "-updatedAt")]
        taskForGETRequest(url: ParseClient.Endpoints.getStudentLocations(query: components.query!).url, response: StudentInformationResponse.self) { (response, error) in
            guard let response = response else{
                completion([], error)
                return
            }
            completion(response.results, nil)
        }
    }
    //Check if a location with the given uniqueKey already exists
    class func checkStudentLocation(uniqueKey: String, completion: @escaping (StudentInformation?, Error?)->Void) {
        var components = URLComponents()
        components.query = "?uniqueKey=\(uniqueKey)"
        taskForGETRequest(url: ParseClient.Endpoints.getStudentLocations(query: components.query!).url, response: StudentInformationResponse.self) { (response, error) in
            guard let response = response else {
                completion(nil, error)
                return
            }
            completion(response.results.first, nil)
        }
    }
    //MARK: POSTing Student Locations
    class func postStudentLocation(studentInformation: StudentInformation, completion: @escaping (StudentInformation?, Error?)->Void) {
        taskForPRequest(url: ParseClient.Endpoints.postStudentLocation.url, body: studentInformation, httpMethod: "POST", response: StudentInformation.self) { (studentInformation, error) in
            guard let studentInformation = studentInformation else{
                completion(nil, error)
                return
            }
            completion(studentInformation, nil)
        }
    }
    //MARK: PUTting Student Locations
    class func updateStudentLocation(studentInformation: StudentInformation, completion: @escaping (StudentInformation?, Error?)->Void) {
        taskForPRequest(url: ParseClient.Endpoints.updateLocation(objectId: studentInformation.objectId!).url, body: studentInformation, httpMethod: "PUT", response: StudentInformation.self) { (studentInformation, error) in
                guard let studentInformation = studentInformation else {
                    completion(nil, error)
                    return
                }
                completion(studentInformation, nil)
        }
    }
    //MARK: Geocoding
    //Get a coordinate from an address string
    class func findLocation(addressString: String, completion: @escaping (CLLocationCoordinate2D?, Error?)->Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(addressString) { (placemarks, error) in
            if error == nil {
                if let placemark = placemarks?[0] {
                    let location = placemark.location!
                    DispatchQueue.main.async {
                        completion(location.coordinate, nil)
                    }
                    return
                }
            }
            DispatchQueue.main.async {
                completion(nil, error)
            }
        }
    }
}
