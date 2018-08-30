//
//  AuthVC.swift
//  Friender
//
//  Created by mac on 7/19/18.
//  Copyright © 2018 storm. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import GoogleSignIn

class SignUpVC: UIViewController, GIDSignInUIDelegate {


    // MARK: - Outlets

    @IBOutlet weak var googleSignInButton: GIDSignInButton!
    
    // MARK: - ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureGoogleSignInButton()

    }
    
    // MARK: - Functions
    
     func configureGoogleSignInButton() {
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
    }
    
    
    // MARK: - Actions
    

    @IBAction func googleSignInButtonTapped(_ sender: Any) {
        
        
        }
}


