//
//  ContactsTableViewController.swift
//  AC3.2-MidtermReview-Contacts
//
//  Created by Tom Seymour on 12/6/16.
//  Copyright © 2016 C4Q-3.2. All rights reserved.
//

import UIKit

let myAPIKey = "wz5WJbz7cRdK2STuA94d"

class ContactsTableViewController: UITableViewController {
    
    
    let contactsEndpoint = "https://api.fieldbook.com/v1/5846e83ef27d1603007e4a88/contacts/"
    
    var contacts: [Contact] = []

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadTableView()
    }
    
    var isFirstTimeLoad = true
    
    func loadTableView() {
        navigationItem.title = "Contacts"
        APIManager.shared.getContacts(endpoint: contactsEndpoint) { (allTheContacts: [Contact]?) in
            if let allTheContacts = allTheContacts {
                DispatchQueue.main.async {
                    self.contacts = allTheContacts
                    self.tableView.reloadData()
                    if !self.isFirstTimeLoad {
                        self.scrollToLast()
                    }
                    self.isFirstTimeLoad = false
                }
            }
        }
    }
    
    func scrollToLast() {
        let lastIndex = IndexPath(row: self.contacts.count - 1, section: 0)
        self.tableView.scrollToRow(at: lastIndex, at: .bottom, animated: true)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath)
        let thisContact = contacts[indexPath.row]
        cell.textLabel?.text = thisContact.firstName + " " + thisContact.lastName
        cell.detailTextLabel?.text = thisContact.email
        
        APIManager.shared.getData(endpoint: thisContact.avatarURL) { (data) in
            if let imageData = data {
                DispatchQueue.main.async {
                    cell.imageView?.image = UIImage(data: imageData)
                    cell.imageView?.layer.cornerRadius = 22
                    cell.imageView?.layer.masksToBounds = true
                    cell.setNeedsLayout()
                }
            }
        }
        return cell
    }
    
// MARK: Navigation
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addContactSegue" {
            if let destinationVC = segue.destination as? ContactDetailViewController {
                destinationVC.viewControllerState = .addContact
            }
            print(" ADD SEGUE! ")
        }
        if segue.identifier == "editContactSegue" {
            if let destinationVC = segue.destination as? ContactDetailViewController,
                let cell = sender as? UITableViewCell,
                let indexPath = tableView.indexPath(for: cell) {
                destinationVC.viewControllerState = .editContact
                destinationVC.contact = contacts[indexPath.row]
            }
            print(" EDIT SEGUE! ")
        }
    }
    
    
}
