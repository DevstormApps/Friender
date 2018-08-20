//
//  PopupViewVC.swift
//  Friender
//
//  Created by mac on 8/18/18.
//  Copyright © 2018 storm. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase

class PopupViewVC: UIViewController, UITextViewDelegate {

    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    
    var placeholderLabel: UILabel!
    var ref: DatabaseReference?
    let user = Auth.auth().currentUser


    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        textView.delegate = self
        placeholderLabel = UILabel()
        placeholderLabel.text = "Enter some text..."
        placeholderLabel.font = UIFont.italicSystemFont(ofSize: (textView.font?.pointSize)!)
        placeholderLabel.sizeToFit()
        textView.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (textView.font?.pointSize)! / 2)
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.isHidden = !textView.text.isEmpty
        self.showAnimate()
        
        // Do any additional setup after loading the view.
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closePopUp(_ sender: AnyObject) {
        self.removeAnimate()
        //self.view.removeFromSuperview()
    }
    
    @IBAction func OKButton(_ sender: Any) {
        print("heyyyyyyy")
        let childRef = Database.database().reference(withPath: "events")
        let user = childRef.child((self.user?.uid)!)
        let titleRef = user.child("title")
        titleRef.setValue(textView.text)
        
    }
    
    @IBAction func pickImage(_ sender: Any) {
    }
    
    func showAnimate()
    {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0;
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        });
    }
    
    func removeAnimate()
    {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0;
        }, completion:{(finished : Bool)  in
            if (finished)
            {
                self.view.removeFromSuperview()
            }
        });
    }
    

}
