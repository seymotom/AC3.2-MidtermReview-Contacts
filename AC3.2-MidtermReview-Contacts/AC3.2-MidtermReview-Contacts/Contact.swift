//
//  Contact.swift
//  AC3.2-MidtermReview-Contacts
//
//  Created by Tom Seymour on 12/6/16.
//  Copyright © 2016 C4Q-3.2. All rights reserved.
//

import Foundation

class Contact {
    let id: Int
    let firstName: String
    let lastName: String
    let company: String
    let role: String
    let email: String
    let avatarURL: String
    let fullName: String
    
    init(id: Int, firstName: String, lastName: String, company: String, role: String, email: String, avatarURL: String, fullName: String) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.company = company
        self.role = role
        self.email = email
        self.avatarURL = avatarURL
        self.fullName = fullName
    }
    
    convenience init?(from dict: [String: Any]) {
        if let id = dict["id"] as? Int,
            let fullName = dict["name"] as? String,
        let company = dict["company"] as? String,
        let role = dict["role"] as? String,
        let email = dict["email"] as? String,
            let avatarURL = dict["avatarurl"] as? String {
            
            let firstName = fullName.components(separatedBy: " ").count > 1 ? fullName.components(separatedBy: " ")[0] : "n/a"
            let lastName = fullName.components(separatedBy: " ").count > 1 ? fullName.components(separatedBy: " ").last! : "n/a"
            self.init(id: id, firstName: firstName, lastName: lastName, company: company, role: role, email: email, avatarURL: avatarURL, fullName: fullName)
            
        } else {
            print("Error occured while parsing data.")
            return nil
        }
    }
    
    static func buildArrayOfContacts(from data: Data) -> [Contact] {
        var allTheContacts: [Contact] = []
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]]
            if let contactsArr = json {
                for contact in contactsArr {
                    if let thisContact = Contact(from: contact) {
                        allTheContacts.append(thisContact)
                    }
                }
                return allTheContacts
            }
        }
        catch {
            print("problem serializing json: \(error)")
        }
        return allTheContacts
    }

    
    
}
