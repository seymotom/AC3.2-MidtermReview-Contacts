//
//  AddContactViewController.swift
//  AC3.2-MidtermReview-Contacts
//
//  Created by Tom Seymour on 12/6/16.
//  Copyright © 2016 C4Q-3.2. All rights reserved.
//

import UIKit

class AddContactViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var avatarImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Add Contact"
        activityIndicator.hidesWhenStopped = true
    }

    
    enum Status: String {
        case Success
        case Failure
    }
    
    func showAlertWith(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "OK", style: .cancel) { (_) in
            _ = self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(okayAction)
        
        present(alert, animated: true, completion: nil)
        
    }
   
    @IBAction func didTapDone(_ sender: UIBarButtonItem) {
        doneButton.isEnabled = false
        view.endEditing(true)
        activityIndicator.startAnimating()
        guard let firstNameString = firstNameTextField.text, let lastNameString = lastNameTextField.text, let emailString = emailTextField.text else {
            showAlertWith(title: "Error", message: "Please, fill in all the fields before submitting")
            return
        }
        
        let addedContactDict: [String: String] = [
            "name" : firstNameString + " " + lastNameString,
            "email" : emailString,
            "company" : "Unemployed",
            "role" : "Chief Couch Officer",
            "avatarurl" : "https://randomuser.me/api/portraits/men/\(arc4random_uniform(UInt32(67))).jpg"
        ]
        APIManager.shared.postData(endpoint: "https://api.fieldbook.com/v1/5846e83ef27d1603007e4a88/contacts/", postDict: addedContactDict) { (response) in
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                if let response = response as? HTTPURLResponse {
                    self.showAlertWith(title: "Success", message: "Your contact was added successfully")
                    print(">>>>>> RESPONSE!!!!!: \(response.statusCode)")
                }
            }
        }
        print(addedContactDict)

        
    }
}
