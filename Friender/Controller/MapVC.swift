//
//  MapVC.swift
//  Friender
//
//  Created by mac on 3/8/18.
//  Copyright © 2018 storm. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseDatabase
import FirebaseStorage
import Firebase
import GoogleSignIn

class MapVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var manager: CLLocationManager?
    var regionRadius: CLLocationDistance = 1000
    let user = Auth.auth().currentUser
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager = CLLocationManager()
        manager?.delegate = self
        manager?.desiredAccuracy = kCLLocationAccuracyBest
        checkAuthorizationStatus()
        mapView.delegate = self
        loadAnnotation()
        centerMapOnUserLocation()
    }
    
    override func viewDidAppear(_ animated: Bool) {

    }
    
    func checkAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedAlways  {
            manager?.startUpdatingLocation()
        } else {
            manager?.requestAlwaysAuthorization()
        }
    }
    
    func loadAnnotation() {
        DatabaseService.instance.events.observeSingleEvent(of: .value) { (snapshot) in
            if let eventSnapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for event in eventSnapshot {
                    if event.hasChild("coordinate") {
                        if let eventDict = event.value as? Dictionary<String, AnyObject> {
                            let coordinateArray = eventDict["coordinate"] as! NSArray
                            let eventCoordinate = CLLocationCoordinate2D(latitude: coordinateArray[0] as! CLLocationDegrees, longitude: coordinateArray[1] as! CLLocationDegrees)
                            let anno = Anno(coordinate: eventCoordinate, key: event.key)
                            self.mapView.addAnnotation(anno)
                        }
                    }
                }
            }
        }
    }
    
    func centerMapOnUserLocation() {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    
    @IBAction func addEventBtnWasPressed(_ sender: Any) {
    
       
    }
    
    @IBAction func centerMapBtnWasPressed(_ sender: Any) {
       centerMapOnUserLocation()

    }


    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkAuthorizationStatus()
        if status == .authorizedAlways {
            mapView.showsUserLocation = true
            mapView.userTrackingMode = .follow
        }
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if  updateLocation.instance.shareLocation == true {
        updateLocation.instance.updateUserLocation(userLocation.coordinate)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotation = annotation as? Anno
            let identifier = "userAnnotation"
            let view: MKAnnotationView
            
            view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            // Get a reference to the storage service using the default Firebase App
            let storage = Storage.storage()
            
            // Create a storage reference
            let storageRef = storage.reference()
            
            //points to the child directory where the profile picture will be saved on firebase
            let profileImageRef = storageRef.child("/User Profile Pictures/"+(user?.uid)!+"/profile_pic.jpg")
            
            if (GIDSignIn.sharedInstance().currentUser != nil) {
                
                let imageUrl = GIDSignIn.sharedInstance().currentUser.profile.imageURL(withDimension: 400).absoluteString
                let url  = NSURL(string: imageUrl)! as URL
                let data = NSData(contentsOf: url)
                
                //upload image to storage
                _ = profileImageRef.putData(data! as Data, metadata: nil) { (metadata, error) in
                    guard let metadata = metadata else {
                        // Uh-oh, an error occurred!
                        return
                    }
                    // Metadata contains file metadata such as size, content-type, and download URL.
                    let size = metadata.size
                    // You can also access to download URL after upload.
                    storageRef.downloadURL { (url, error) in
                        guard let downloadURL = url else {
                            // Uh-oh, an error occurred!
                            return
                        }
                    }
                    
                }
                let pinPic = UIImage(data: data! as Data)
                let cropsToSquare = pinPic?.cropsToSquare()
                let size = CGSize(width: 30, height: 30)
                UIGraphicsBeginImageContext(size)
                cropsToSquare!.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
                let resizedPinPic = UIGraphicsGetImageFromCurrentImageContext()
                view.contentMode = .scaleAspectFill
                view.layer.cornerRadius = (resizedPinPic?.size.width)! / 2
                view.clipsToBounds = true
                view.image = resizedPinPic
                
            }
            return view
        
        }
    
}

extension UIImage {
    func cropsToSquare() -> UIImage {
        let refWidth = CGFloat((self.cgImage!.width))
        let refHeight = CGFloat((self.cgImage!.height))
        let cropSize = refWidth > refHeight ? refHeight : refWidth
        
        let x = (refWidth - cropSize) / 2.0
        let y = (refHeight - cropSize) / 2.0
        
        let cropRect = CGRect(x: x, y: y, width: cropSize, height: cropSize)
        let imageRef = self.cgImage?.cropping(to: cropRect)
        let cropped = UIImage(cgImage: imageRef!, scale: 0.0, orientation: self.imageOrientation)
        
        return cropped
    }

}
