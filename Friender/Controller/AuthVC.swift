//
//  AuthVC.swift
//  Friender
//
//  Created by mac on 7/19/18.
//  Copyright © 2018 storm. All rights reserved.
//

import UIKit

class AuthVC: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailField.delegate = self
        passwordField.delegate = self
    }

    @IBAction func loginButtonWasPressed(_ sender: Any) {
        if emailField != nil || passwordField != nil {
            AuthService.instance.loginUser(email: emailField.text!, password: passwordField.text!) { (success, loginError) in
                if success {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    print(String(describing:loginError?.localizedDescription))
                }
                
                AuthService.instance.registerUser(email: self.emailField.text!, password: self.passwordField.text!, userCreationComplete: { (success, registerError) in
                    if success {
                        AuthService.instance.loginUser(email: self.emailField.text!, password: self.passwordField.text!, loginComplete: { (success, nil) in
                            print("Successfully registered user")
                        })
                    } else {
                        print(String(describing: registerError?.localizedDescription))
                    }
                })
            }
        }
    }
    
}

extension AuthVC: UITextFieldDelegate {
    
    
}
