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

class addEventVC: UIViewController, UITextFieldDelegate {
    
    let tapRec = UITapGestureRecognizer()
    
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var addEventButton: UIButton!
    @IBOutlet weak var eventTitleTextField: MDCTextField!
    @IBOutlet weak var addImageButton: UIBarButtonItem!
    @IBOutlet weak var progressView: UIProgressView!
    
    // MARK: - Variables
    fileprivate let picker = UIImagePickerController()
    fileprivate var storageImagePath = ""
    fileprivate var ref: DatabaseReference!
    fileprivate var storageRef: StorageReference!
    fileprivate var storageUploadTask: StorageUploadTask!
    let color = UIColor(red:0.65, green:0.42, blue:0.95, alpha:1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        storageRef = Storage.storage().reference()
        picker.delegate = self
        eventTitleTextField.placeholder = "Tell people about your event"
        eventTitleTextField.cursorColor = UIColor(red:0.65, green:0.42, blue:0.95, alpha:1.0)
        eventTitleTextField.delegate = self
        progressView.progress = 0
        addEventButton.isUserInteractionEnabled = false
        addEventButton.isEnabled = false
        addEventButton.alpha = 0.5

        self.setupHideKeyboardOnTap()


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

    
    func camera()
    {
        let myPickerController = UIImagePickerController()
        myPickerController.delegate = self;
        myPickerController.sourceType = UIImagePickerControllerSourceType.camera
        
        self.present(myPickerController, animated: true, completion: nil)
        
    }
    
    func photoLibrary()
    {
        
        let myPickerController = UIImagePickerController()
        myPickerController.delegate = self;
        myPickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
        
        self.present(myPickerController, animated: true, completion: nil)
        
    }
    
    func showActionSheet() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: UIAlertActionStyle.default, handler: { (alert:UIAlertAction!) -> Void in
            self.camera()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Gallery", style: UIAlertActionStyle.default, handler: { (alert:UIAlertAction!) -> Void in
            self.photoLibrary()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
        
    }
    
    
     func textFieldDidBeginEditing(_ textField: UITextField) {
        if eventTitleTextField.text != "" && eventImage.image != nil {
            addEventButton.isUserInteractionEnabled = true
            addEventButton.isEnabled = true
            addEventButton.alpha = 1

        } else {
            addEventButton.isUserInteractionEnabled = false
            addEventButton.isEnabled = false
            addEventButton.alpha = 0.5

        }
        }
    
    @IBAction func addEventButtonWasPressed(_ sender: Any) {
        // Get properties for the unicorn-to-be-created
        let title = self.eventTitleTextField.text ?? ""
        let event = Event(imagePath: storageImagePath, title: title, key: user!.uid)
        // Create the unicorn and record it
        writeEventToDatabase(event)
        ref.child("events").child(user!.uid).child("timestamp").setValue(ServerValue.timestamp())
        ref.child("events").child(user!.uid).child("duration").setValue(Int(3000000))

    }
    
    @IBAction func addImageButtonWasPressed(_ sender: Any) {
        showActionSheet()
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
                addEventButton.isUserInteractionEnabled = false
                addEventButton.isEnabled = false
                addEventButton.alpha = 0.5
                
                return
        }
        
        if eventTitleTextField.text != "" {
            addEventButton.isUserInteractionEnabled = true
            addEventButton.isEnabled = true
            addEventButton.alpha = 1
        }
        
        // 2. Create a unique image path for image. In the case I am using the googleAppId of my account appended to the interval between 00:00:00 UTC on 1 January 2001 and the current date and time as an Integer and then I append .jpg. You can use whatever you prefer as long as it ends up unique.
        let ref = Storage.storage().reference()
        let uid = user?.uid
        let imagePath = ref.child("/events/"+(user?.uid)!+"/event_pic.jpg")
        
        // 3. Set up metadata with appropriate content type
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        // 4. Show activity indicator
        showNetworkActivityIndicator = true
        
        // 5. Start upload task
        storageUploadTask = imagePath.putData(imageData, metadata: metadata, completion: { (metadata, error) in
            // 6. Hide activity indicator because uploading is done with or without an error
            self.showNetworkActivityIndicator = false
            
                        guard error == nil else {
                print("Error uploading: \(error!)")
                return
            }
            self.storageUploadTask.observe(.progress, handler: { (snapshot) in
                if let completedUnitCount = snapshot.progress?.completedUnitCount, let totalUnitCount =
                    
                    snapshot.progress?.totalUnitCount {
                    
                    let uploadProgress:Float = Float(completedUnitCount) / Float(totalUnitCount)
                    self.progressView.progress = uploadProgress   }
            })

            self.uploadSuccess(uid!, image)
        })
    
}
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

}

extension UIViewController {
    /// Call this once to dismiss open keyboards by tapping anywhere in the view controller
    func setupHideKeyboardOnTap() {
        self.view.addGestureRecognizer(self.endEditingRecognizer())
        self.navigationController?.navigationBar.addGestureRecognizer(self.endEditingRecognizer())
    }
    
    /// Dismisses the keyboard from self.view
    private func endEditingRecognizer() -> UIGestureRecognizer {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(self.view.endEditing(_:)))
        tap.cancelsTouchesInView = false
        return tap
    }
}
