//
//  ContactDetailViewController.swift
//  AC3.2-MidtermReview-Contacts
//
//  Created by Tom Seymour on 12/6/16.
//  Copyright © 2016 C4Q-3.2. All rights reserved.
//

import UIKit

enum ContactDetailViewControllerState {
    case addContact
    case editContact
}

class ContactDetailViewController: UIViewController, UITextFieldDelegate {
    
    var viewControllerState: ContactDetailViewControllerState = .addContact
    
    var contact: Contact?
    
    let contactsEndpoint = "https://api.fieldbook.com/v1/5846e83ef27d1603007e4a88/contacts/"
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var deleteButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem?.title = "Cancel"
        switch viewControllerState {
        case .addContact:
            loadAddContactView()
        case .editContact:
            loadEditContactView()
        }
        activityIndicator.hidesWhenStopped = true
    }
    
    func loadAddContactView() {
        navigationItem.title = "Add Contact"
        deleteButton.isHidden = true
    }
    
    func loadEditContactView() {
        if let thisContact = contact {
            navigationItem.title = thisContact.fullName
        }
        deleteButton.isHidden = false
        displayCurrentContact()
    }
    
    func displayCurrentContact() {
        if let thisContact = contact {
            firstNameTextField.text = thisContact.firstName
            lastNameTextField.text = thisContact.lastName
            emailTextField.text = thisContact.email
            APIManager.shared.makeRequest(httpMethod: .get, endpoint: thisContact.avatarURL) { (_, data) in
                DispatchQueue.main.async {
                    self.avatarImageView.image = UIImage(data: data)
                    self.avatarImageView.layer.cornerRadius = 85
                    self.avatarImageView.layer.masksToBounds = true
                    self.reloadInputViews()
                }
            }
        }
    }
    
    func makeRequest() {
        doneButton.isEnabled = false
        activityIndicator.startAnimating()
        guard let firstNameString = firstNameTextField.text, let lastNameString = lastNameTextField.text, let emailString = emailTextField.text else {
            showAlertWith(title: "Error", message: "Please, fill in all the fields before submitting")
            return
        }
        switch viewControllerState {
        case .addContact:
            let addedContactDict: [String: Any] = [
                "name" : firstNameString + " " + lastNameString,
                "email" : emailString,
                "company" : "Unemployed",
                "role" : "Chief Couch Officer",
                "avatarurl" : "https://randomuser.me/api/portraits/lego/\(arc4random_uniform(UInt32(9))).jpg"
            ]
            APIManager.shared.makeRequest(httpMethod: .post, endpoint: self.contactsEndpoint, bodyDict: addedContactDict) { (response, _) in
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    if let response = response as? HTTPURLResponse {
                        switch response.statusCode {
                        case 200...299:
                            self.showAlertWith(title: "Success", message: "Your contact was added successfully")
                            print("HTTP Response code: \(response.statusCode)")
                        default:
                            self.showAlertWith(title: "Failure", message: "Your contact was not added successfully")
                            print("HTTP Response code: \(response.statusCode)")
                        }
                    }
                }
            }
            
        case .editContact:
            print("******EDIT******")
            guard let thisContact = contact else { return }
            let editedContactDict: [String: Any] = [
                "name" : firstNameString + " " + lastNameString,
                "email" : emailString,
                "company" : thisContact.company,
                "role" : thisContact.role,
                "avatarurl" : thisContact.avatarURL
            ]
            APIManager.shared.makeRequest(httpMethod: .patch, endpoint: self.contactsEndpoint + String(thisContact.id), bodyDict: editedContactDict) { (response, _) in
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    if let response = response as? HTTPURLResponse {
                        switch response.statusCode {
                        case 200...299:
                            self.showAlertWith(title: "Cloud Contact Updated", message: "")
                            print("HTTP Response code: \(response.statusCode)")
                        default:
                            self.showAlertWith(title: "Cloud Update Failed", message: "Your contact was not updated successfully.")
                            print("HTTP Response code: \(response.statusCode)")
                        }
                    }
                }
            }
        }
    }
    
    func makeDeleteRequest() {
        activityIndicator.startAnimating()
        if let thisContact = contact {
            APIManager.shared.makeRequest(httpMethod: .delete, endpoint: self.contactsEndpoint + String(thisContact.id)) { (response, _) in
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    if let response = response as? HTTPURLResponse {
                        switch response.statusCode {
                        case 200...299:
                            self.showAlertWith(title: "Success", message: "Contact was deleted successfully")
                        default:
                            self.showAlertWith(title: "Failure", message: "Contact was not deleted successfully")
                        }
                    }
                }
            }
        }
    }

    @IBAction func didTapDone(_ sender: UIBarButtonItem) {
        view.endEditing(true)
        switch viewControllerState {
        case .editContact:
                showCancelAlert(title: "Update Contact?", message: "Are you sure you want to apply your changes to this contact?")
        case .addContact:
            makeRequest()
        }
    }
    
    @IBAction func didPressDelete(_ sender: UIButton) {
        deleteButton.isEnabled = false
        guard let thisContact = contact else { return }
        showDeleteAlert(title: "Delete?", message: "Are you sure you want to delete \(thisContact.fullName)?")
    }
    
    // MARK: Alert Controllers
    
    func showDeleteAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (_) in
            self.makeDeleteRequest()
        }
        alertController.addAction(deleteAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showCancelAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        let okayAction = UIAlertAction(title: "OK", style: .default) { (_) in
                self.makeRequest()
        }
        alertController.addAction(okayAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showAlertWith(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "OK", style: .cancel) { (_) in
            _ = self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(okayAction)
        
        present(alert, animated: true, completion: nil)
    }

}
