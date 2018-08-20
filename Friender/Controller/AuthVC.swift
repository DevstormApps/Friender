//
//  AuthVC.swift
//  Friender
//
//  Created by mac on 7/19/18.
//  Copyright © 2018 storm. All rights reserved.
//

import UIKit

class SignUpVC: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailField.delegate = self
        passwordField.delegate = self
        self.hideKeyboardWhenTappedAround()
    }

    @IBAction func loginButtonWasPressed(_ sender: Any) {
        if emailField != nil || passwordField != nil {
            AuthService.instance.loginUser(email: emailField.text!, password: passwordField.text!) { (success, loginError) in
                if success {
                    self.performSegue(withIdentifier: "goToTabBar", sender: self)
                } else {
                    print(String(describing:loginError?.localizedDescription))
                }
                
                AuthService.instance.registerUser(email: self.emailField.text!, password: self.passwordField.text!, userCreationComplete: { (success, registerError) in
                    if success {
                        AuthService.instance.loginUser(email: self.emailField.text!, password: self.passwordField.text!, loginComplete: { (success, nil) in
                            self.performSegue(withIdentifier: "goToTabBar", sender: self)
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

extension SignUpVC: UITextFieldDelegate {
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

