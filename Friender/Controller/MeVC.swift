//
//  MeVC.swift
//  Friender
//
//  Created by mac on 9/13/18.
//  Copyright © 2018 storm. All rights reserved.
//

import UIKit
import FirebaseUI
import FirebaseDatabase
import Firebase

class MeVC: UIViewController {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var username: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DatabaseService.instance.users.child((user?.uid)!).observe(.value) { (snapshot) in
            let snapshotValue = snapshot.value as! [String: AnyObject]
            let usernameText = snapshotValue["name"] as! String
            self.username.text = usernameText
        }
        profileImage.layer.cornerRadius = profileImage.bounds.size.width / 2
        profileImage.clipsToBounds = true
        
        let ref = Storage.storage().reference()
        let path = ref.child("/User Profile Pictures/"+(user?.uid)!+"/profile_pic.jpg")
        profileImage.sd_setImage(with: path)

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func logout(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
           // performSegue(withIdentifier: "goBackToSignIn", sender: self)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
    }
}
