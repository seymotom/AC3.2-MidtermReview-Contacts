//
//  APIManager.swift
//  AC3.2-MidtermReview-Contacts
//
//  Created by Tom Seymour on 12/6/16.
//  Copyright © 2016 C4Q-3.2. All rights reserved.
//

import Foundation

class APIManager {
    
    static let shared = APIManager()
    private init() {}
    
    func getContacts(endpoint: String, completionHandler: @escaping ( [Contact]?) -> Void ) {
        
        guard let url = URL(string: endpoint) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Basic a2V5LTE6d3o1V0piejdjUmRLMlNUdUE5NGQ=", forHTTPHeaderField: "Authorization")
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let error = error {
                print(">>>> There was an error with the request: \(error)")
            }
            if let response = response {
                print(">>>> Request response: \(response)")
            }
            if let data = data {
                print(">>>> Got some data: \(data)")
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]]
                    if let contactsArr = json {
                        var allTheContacts: [Contact] = []
                        for contact in contactsArr {
                            if let thisContact = Contact(from: contact) {
                                allTheContacts.append(thisContact)
                            }
                        }
                        completionHandler(allTheContacts)
                    }
                }
                catch {
                    print("problem parsing json: \(error)")
                }
            }
            }.resume()
    }
    
    func getData(endpoint: String, completionHandler: @escaping (Data?) -> Void) {
        guard let url = URL(string: endpoint) else { return }
        let session = URLSession(configuration: URLSessionConfiguration.default)
        session.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) in
            if error != nil {
                print("Error encountered with data task:  \(error)")
            }
            if let validData = data {
                completionHandler(validData)
            }
            }.resume()
    }
    
    func postData(endpoint: String, postDict: [String: String], completionHandler: @escaping (URLResponse?) -> Void) {
        guard let url = URL(string: endpoint) else { return }
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Basic a2V5LTE6d3o1V0piejdjUmRLMlNUdUE5NGQ=", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: postDict, options: [])
        }
        catch {
            print("Error converting to data: \(error)")
            return
        }
        
        let session: URLSession = URLSession(configuration: .default)
        session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if let error = error {
                print(">>>> There was an error with the request: \(error)")
            }
            if let response = response {
                print(">>>> Request response: \(response)")
                completionHandler(response)
            }
            if let myData = data {

                do {
                    let json = try JSONSerialization.jsonObject(with: myData, options: []) as? [String: Any]
                    if let validJson = json {
                        print(">>>> SUCCESS")
                        print(validJson)
                        
                    }
                }
                catch {
                    print("Error with the session for this post request: \(error)")
                }
            }
            }.resume()
    }
    
    func putData(endpoint: String, putDict: [String: Any], completionHandler: @escaping (URLResponse?) -> Void) {
        guard let url = URL(string: endpoint) else { return }
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Basic a2V5LTE6d3o1V0piejdjUmRLMlNUdUE5NGQ=", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "PATCH"
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: putDict, options: [])
        }
        catch {
            print("Error converting to data: \(error)")
            return
        }
        
        let session: URLSession = URLSession(configuration: .default)
        session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if let error = error {
                print(">>>> There was an error with the request: \(error)")
            }
            if let response = response {
                print(">>>> Request response: \(response)")
                completionHandler(response)
            }
            if let myData = data {
                
                do {
                    let json = try JSONSerialization.jsonObject(with: myData, options: []) as? [String: Any]
                    if let validJson = json {
                        print(">>>> SUCCESS")
                        print(validJson)
                    }
                }
                catch {
                    print("Error with the session for this post request: \(error)")
                }
            }
            }.resume()
    }
    
    
    func deleteData(endpoint: String, completeionHandler: @escaping (URLResponse?) -> Void ) {
        guard let url = URL(string: endpoint) else { return }
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Basic a2V5LTE6d3o1V0piejdjUmRLMlNUdUE5NGQ=", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "DELETE"
        let session = URLSession(configuration: .default)
        session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let error = error {
                print("Error: \(error)")
            }
            if let response = response {
                print(">>>>>> RESPONSE: \(response)")
                completeionHandler(response)
            }
            
            }.resume()
    }
}
