////
////  PopupViewVC.swift
////  Friender
////
////  Created by mac on 8/18/18.
////  Copyright © 2018 storm. All rights reserved.
////
//
//import UIKit
//import FirebaseDatabase
//import Firebase
//
//
//class PopupViewVC: UIViewController, UITextViewDelegate {
//
//
//    @IBOutlet weak var imageView: UIImageView!
//    @IBOutlet weak var textView: UITextView!
//
//    var placeholderLabel: UILabel!
//
//    // MARK: - Variables
//    fileprivate let picker = UIImagePickerController()
//    fileprivate var storageImagePath = ""
//    fileprivate var ref: DatabaseReference!
//    fileprivate var storageRef: StorageReference!
//    fileprivate var storageUploadTask: StorageUploadTask!
//
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
//        prepareTextView()
//        // Setup references for database and for storage
//        ref = Database.database().reference()
//        storageRef = Storage.storage().reference()
//        picker.delegate = self
//
//        self.showAnimate()
//    }
//
//    // Setup for activity indicator to be shown when uploading image
//    fileprivate var showNetworkActivityIndicator = false {
//        didSet {
//            UIApplication.shared.isNetworkActivityIndicatorVisible = showNetworkActivityIndicator
//        }
//    }
//
//    // MARK: - Functions
//    fileprivate func writeEventToDatabase(_ event: Event) {
//        // Access the "unicorns" child reference and then access (create) a unique child reference within it and finally set its value
//        ref.child("events").child(user!.uid).setValue(event.toAnyObject())
//    }
//
//    fileprivate func uploadSuccess(_ storagePath: String, _ storageImage: UIImage) {
//
//        // Update the unicorn image view with the selected image
//        imageView.image = storageImage
//        // Updated global variable for the storage path for the selected image
//        storageImagePath = storagePath
//
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        // If VC is popping, stop showing networking activity indicator and cancel storageUploadTask if any
//        if self.isMovingFromParentViewController {
//            showNetworkActivityIndicator = false
//            storageUploadTask?.cancel()
//        }
//    }
//
//
//    func textViewDidChange(_ textView: UITextView) {
//        placeholderLabel.isHidden = !textView.text.isEmpty
//    }
//
//    func prepareTextView() {
//        textView.delegate = self
//        placeholderLabel = UILabel()
//        placeholderLabel.text = "Enter some text..."
//        placeholderLabel.font = UIFont.italicSystemFont(ofSize: (textView.font?.pointSize)!)
//        placeholderLabel.sizeToFit()
//        textView.addSubview(placeholderLabel)
//        placeholderLabel.frame.origin = CGPoint(x: 5, y: (textView.font?.pointSize)! / 2)
//        placeholderLabel.textColor = UIColor.lightGray
//        placeholderLabel.isHidden = !textView.text.isEmpty
//    }
//
//    // MARK: Actions
//
//    @IBAction func closePopUp(_ sender: AnyObject) {
//        self.removeAnimate()
//        //self.view.removeFromSuperview()
//    }
//
//    @IBAction func OKButton(_ sender: Any) {
//        // Get properties for the unicorn-to-be-created
//        let title = self.textView.text ?? ""
//        let event = Event(imagePath: storageImagePath, title: title, key: user!.uid)
//        updateLocation.instance.shareLocation = true
//        // Create the unicorn and record it
//        writeEventToDatabase(event)
//        removeAnimate()
//    }
//
//    @IBAction func pickImage(_ sender: Any) {
//        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
//
//            picker.sourceType = .photoLibrary
//        }
//
//        present(picker, animated: true, completion: nil)
//    }
//
//    // MARK: - Animate
//
//    func showAnimate()
//    {
//        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
//        self.view.alpha = 0.0;
//        UIView.animate(withDuration: 0.25, animations: {
//            self.view.alpha = 1.0
//            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
//        });
//    }
//
//    func removeAnimate()
//    {
//        UIView.animate(withDuration: 0.25, animations: {
//            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
//            self.view.alpha = 0.0;
//        }, completion:{(finished : Bool)  in
//            if (finished)
//            {
//                self.view.removeFromSuperview()
//            }
//        });
//    }
//
//}
//
//// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
//extension PopupViewVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
//        picker.dismiss(animated: true, completion: nil)
//
//        // 1. Get image data from selected image
//        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage,
//            let imageData = UIImageJPEGRepresentation(image, 0.5) else {
//                print("Could not get Image JPEG Representation")
//                return
//        }
//
//        // 2. Create a unique image path for image. In the case I am using the googleAppId of my account appended to the interval between 00:00:00 UTC on 1 January 2001 and the current date and time as an Integer and then I append .jpg. You can use whatever you prefer as long as it ends up unique.
//        let imagePath = Auth.auth().app!.options.googleAppID + "/\(Int(Date.timeIntervalSinceReferenceDate * 1000)).jpg"
//
//        // 3. Set up metadata with appropriate content type
//        let metadata = StorageMetadata()
//        metadata.contentType = "image/jpeg"
//
//        // 4. Show activity indicator
//        showNetworkActivityIndicator = true
//
//        // 5. Start upload task
//        storageUploadTask = storageRef.child(imagePath).putData(imageData, metadata: metadata) { (_, error) in
//            // 6. Hide activity indicator because uploading is done with or without an error
//            self.showNetworkActivityIndicator = false
//
//            guard error == nil else {
//                print("Error uploading: \(error!)")
//                return
//            }
//            self.uploadSuccess(imagePath, image)
//        }
//    }
//
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        picker.dismiss(animated: true, completion: nil)
//    }
//}
