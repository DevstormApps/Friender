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
import GoogleMaps
import GooglePlaces

class MapVC: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    @IBOutlet weak var mapView: GMSMapView!
    
    var manager: CLLocationManager?
    var regionRadius: CLLocationDistance = 1000
    let user = Auth.auth().currentUser
    var storageRef: StorageReference!
    var storageDownloadTask: StorageDownloadTask!
    var eventCoords: CLLocationCoordinate2D?

    override func viewDidLoad() {
        super.viewDidLoad()
        manager = CLLocationManager()
        manager?.delegate = self
        manager?.desiredAccuracy = kCLLocationAccuracyBest
        mapView.delegate = self
        checkAuthorizationStatus()
        storageRef = Storage.storage().reference()
        loadAnnotation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadAnnotation()
    }
    
    func checkAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedAlways  {
            manager?.startUpdatingLocation()
        } else {
            manager?.requestAlwaysAuthorization()
        }
    }
    
    func loadAnnotation() {

        DatabaseService.instance.acceptedEventRequesters.child((user?.uid)!).observeSingleEvent(of: .value) { (snapshot) in
            if let eventSnapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for event in eventSnapshot {
                    if event.hasChild("coordinate") {
                        if let eventDict = event.value as? Dictionary<String, AnyObject> {
                            let coordinateArray = eventDict["coordinate"] as! NSArray
                            let eventCoordinate = CLLocationCoordinate2D(latitude: coordinateArray[0] as! CLLocationDegrees, longitude: coordinateArray[1] as! CLLocationDegrees)
                                    let path = self.storageRef.child("/User Profile Pictures/"+(event.key)+"/profile_pic.jpg")

                                    self.storageDownloadTask = path.getData(maxSize: 1024 * 1024 * 12, completion: { (data, error) in
                                    if let data = data {
                                    let image = UIImage(data: data)

//                                    let anno = Anno(coordinate: eventCoordinate, key: event.key, image: image!)
//                                    self.mapView.addAnnotation(anno)
//                                        self.showRouteOnMap(pickupCoordinate: self.mapView.userLocation.coordinate, destinationCoordinate: eventCoordinate)
//                                }
                            let marker = GMSMarker()
                            marker.position = eventCoordinate
                            let croppedImage = image!.cropsToSquare()
                            let pinImage = self.imageWithImage(image: croppedImage, scaledToSize:CGSize(width: 35.0, height: 35.0))
                            let markerView = UIImageView(image: pinImage)
                            markerView.layer.cornerRadius = markerView.bounds.size.width / 2
                            markerView.clipsToBounds = true
                            marker.iconView = markerView
                            marker.map = self.mapView
                                }
                            })
                        }
                    }
                }
            }
        }
        
    }
    
    func imageWithImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }

    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        eventCoords = coordinate
        performSegue(withIdentifier: "goToEventComposer", sender: self)
    }


    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkAuthorizationStatus()
        if status == .authorizedAlways {
            mapView.isMyLocationEnabled = true
            mapView.settings.myLocationButton = true
        }
    }
    
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        if let = annotation as? Anno {
//            let identifier = "userAnnotation"
//            let view: MKAnnotationView
//            view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
//            let image = annotation.image
//            let croppedImage = image.cropsToSquare()
//            let size = CGSize(width: 30, height: 30)
//            UIGraphicsBeginImageContext(size)
//            croppedImage.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
//            let pinImage = UIGraphicsGetImageFromCurrentImageContext()
//            view.contentMode = .scaleAspectFill
//            view.layer.cornerRadius = (pinImage?.size.width)! / 2
//            view.clipsToBounds = true
//            view.image = pinImage
//
//
//            return view
//
//        }
//        return nil
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToEventComposer" {
            if let destinationVC = segue.destination as? EventComposerVC {
                destinationVC.eventCoords = self.eventCoords
            }
        }
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
