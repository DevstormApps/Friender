//
//  AddEventVC.swift
//  Friender
//
//  Created by mac on 8/29/18.
//  Copyright © 2018 storm. All rights reserved.
//

import UIKit
import MaterialComponents
import Firebase
import FirebaseDatabase
import FirebaseStorage

class addEventVC: UIViewController {
    
    let tapRec = UITapGestureRecognizer()
    
    @IBOutlet weak var eventImage: UIImageView!
    
    @IBOutlet weak var addEventButton: UIButton!
    @IBOutlet weak var eventTitleTextField: MDCTextField!
    // MARK: - Variables
    fileprivate let picker = UIImagePickerController()
    fileprivate var storageImagePath = ""
    fileprivate var ref: DatabaseReference!
    fileprivate var storageRef: StorageReference!
    fileprivate var storageUploadTask: StorageUploadTask!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        storageRef = Storage.storage().reference()
        picker.delegate = self
        tapRec.addTarget(self, action: Selector(("tappedView")))
        eventImage.addGestureRecognizer(tapRec)
        self.hideKeyboard()

        
    }
    
    func tappedView(){
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            
            picker.sourceType = .photoLibrary
        }
        
        present(picker, animated: true, completion: nil)
    }
    
    
    // Setup for activity indicator to be shown when uploading image
    fileprivate var showNetworkActivityIndicator = false {
        didSet {
            UIApplication.shared.isNetworkActivityIndicatorVisible = showNetworkActivityIndicator
        }
    }
    
    // MARK: - Functions
    fileprivate func writeEventToDatabase(_ event: Event) {
        // Access the "unicorns" child reference and then access (create) a unique child reference within it and finally set its value
        ref.child("events").child(user!.uid).setValue(event.toAnyObject())
    }
    
    fileprivate func uploadSuccess(_ storagePath: String, _ storageImage: UIImage) {
        
        // Update the unicorn image view with the selected image
        eventImage.image = storageImage
        // Updated global variable for the storage path for the selected image
        storageImagePath = storagePath
        
    }
    
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    @IBAction func addEventButtonWasPressed(_ sender: Any) {
        // Get properties for the unicorn-to-be-created
        let title = self.eventTitleTextField.text ?? ""
        let event = Event(imagePath: storageImagePath, title: title, key: user!.uid)
        // Create the unicorn and record it
        writeEventToDatabase(event)
    }
    
    

}
// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension addEventVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        // 1. Get image data from selected image
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage,
            let imageData = UIImageJPEGRepresentation(image, 0.5) else {
                print("Could not get Image JPEG Representation")
                return
        }
        
        // 2. Create a unique image path for image. In the case I am using the googleAppId of my account appended to the interval between 00:00:00 UTC on 1 January 2001 and the current date and time as an Integer and then I append .jpg. You can use whatever you prefer as long as it ends up unique.
        let imagePath = Auth.auth().app!.options.googleAppID + "/\(Int(Date.timeIntervalSinceReferenceDate * 1000)).jpg"
        
        // 3. Set up metadata with appropriate content type
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        // 4. Show activity indicator
        showNetworkActivityIndicator = true
        
        // 5. Start upload task
        storageUploadTask = storageRef.child(imagePath).putData(imageData, metadata: metadata) { (_, error) in
            // 6. Hide activity indicator because uploading is done with or without an error
            self.showNetworkActivityIndicator = false
            
            guard error == nil else {
                print("Error uploading: \(error!)")
                return
            }
            self.uploadSuccess(imagePath, image)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension UIViewController
{
    func hideKeyboard()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
}

