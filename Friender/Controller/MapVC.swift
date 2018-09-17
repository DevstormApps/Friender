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
    var storageRef: StorageReference!
    var storageDownloadTask: StorageDownloadTask!

    override func viewDidLoad() {
        super.viewDidLoad()
        manager = CLLocationManager()
        manager?.delegate = self
        manager?.desiredAccuracy = kCLLocationAccuracyBest
        checkAuthorizationStatus()
        mapView.delegate = self
        storageRef = Storage.storage().reference()
        loadAnnotation()
        centerMapOnUserLocation()
        
//        let ref = Database.database().reference()
//        ref.child("user_profiles").observeSingleEvent(of: .value, with: { snapshot in
//            print(snapshot.childrenCount) // I got the expected number of items
//            for rest in snapshot.children.allObjects as! [DataSnapshot] {
//                let dict = rest.value as? [String : AnyObject] ?? [:]
//                print(dict["profile_picture"]!)
//            }
//        })

    }
    
    func checkAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedAlways  {
            manager?.startUpdatingLocation()
        } else {
            manager?.requestAlwaysAuthorization()
        }
    }
    
    func loadAnnotation() {
        DatabaseService.instance.accepted.child((user?.uid)!).observeSingleEvent(of: .value) { (snapshot) in
            if let acceptedSnapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for user in acceptedSnapshot {
                    if user.key != Auth.auth().currentUser?.uid {
                        if user.hasChild("coordinate") {
                            if let eventDict = user.value as? Dictionary<String, AnyObject> {
                                let coordinateArray = eventDict["coordinate"] as! NSArray
                                let eventCoordinate = CLLocationCoordinate2D(latitude: coordinateArray[0] as! CLLocationDegrees, longitude: coordinateArray[1] as! CLLocationDegrees)
                                
                                let path = self.storageRef.child("/User Profile Pictures/"+(user.key)+"/profile_pic.jpg")
                                
                                self.storageDownloadTask = path.getData(maxSize: 1024 * 1024 * 12, completion: { (data, error) in
                                    if let data = data {
                                        let image = UIImage(data: data)
                                        let anno = Anno(coordinate: eventCoordinate, key: user.key, image: image!)
                                        self.mapView.addAnnotation(anno)
                                        
                                    }
                                })
                                
                                
                            }
                        }
                    }
                   
                }
            }
        }
        
        DatabaseService.instance.accepter.child((user?.uid)!).observeSingleEvent(of: .value) { (snapshot) in
            if let accepterSnapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for user in accepterSnapshot {
                    if user.key != Auth.auth().currentUser?.uid {
                        if user.hasChild("coordinate") {
                            if let eventDict = user.value as? Dictionary<String, AnyObject> {
                                let coordinateArray = eventDict["coordinate"] as! NSArray
                                let eventCoordinate = CLLocationCoordinate2D(latitude: coordinateArray[0] as! CLLocationDegrees, longitude: coordinateArray[1] as! CLLocationDegrees)
                            
                                let path = self.storageRef.child("/User Profile Pictures/"+(user.key)+"/profile_pic.jpg")
                                self.storageDownloadTask = path.getData(maxSize: 1024 * 1024 * 12, completion: { (data, error) in
                                    if let data = data {
                                        let image = UIImage(data: data)
                                        let anno = Anno(coordinate: eventCoordinate, key: user.key, image: image!)
                                        self.mapView.addAnnotation(anno)
                                        
                                    }
                                })
                            }
                        }

                    }
                }
            }
        }
    }
//
//        DatabaseService.instance.events.observeSingleEvent(of: .value) { (snapshot) in
//            if let eventSnapshot = snapshot.children.allObjects as? [DataSnapshot] {
//                for event in eventSnapshot {
//                    if event.hasChild("coordinate") {
//                        if let eventDict = event.value as? Dictionary<String, AnyObject> {
//                            let coordinateArray = eventDict["coordinate"] as! NSArray
//                            let eventCoordinate = CLLocationCoordinate2D(latitude: coordinateArray[0] as! CLLocationDegrees, longitude: coordinateArray[1] as! CLLocationDegrees)
//                            let anno = Anno(coordinate: eventCoordinate, key: event.key)
//                            self.mapView.addAnnotation(anno)
//                        }
//                    }
//                }
//            }
//        }
//
    
    func centerMapOnUserLocation() {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func showRouteOnMap(pickupCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) {
        
        let sourcePlacemark = MKPlacemark(coordinate: pickupCoordinate, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate, addressDictionary: nil)
        
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        let sourceAnnotation = MKPointAnnotation()
        
        if let location = sourcePlacemark.location {
            sourceAnnotation.coordinate = location.coordinate
        }
        
        let destinationAnnotation = MKPointAnnotation()
        
        if let location = destinationPlacemark.location {
            destinationAnnotation.coordinate = location.coordinate
        }
        
        self.mapView.showAnnotations([sourceAnnotation,destinationAnnotation], animated: true )
        
        let directionRequest = MKDirectionsRequest()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .automobile
        
        // Calculate the direction
        let directions = MKDirections(request: directionRequest)
        
        directions.calculate {
            (response, error) -> Void in
            
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                
                return
            }
            
            let route = response.routes[0]
            
            self.mapView.add((route.polyline), level: MKOverlayLevel.aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(overlay: overlay)
        
        renderer.strokeColor = UIColor(red: 17.0/255.0, green: 147.0/255.0, blue: 255.0/255.0, alpha: 1)
        
        renderer.lineWidth = 5.0
        
        return renderer
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
    
        updateLocation.instance.updateUserLocation(userLocation.coordinate)
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? Anno {
            let identifier = "userAnnotation"
            let view: MKAnnotationView
            view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            let image = annotation.image
            let croppedImage = image.cropsToSquare()
            let size = CGSize(width: 30, height: 30)
            UIGraphicsBeginImageContext(size)
            croppedImage.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            let pinImage = UIGraphicsGetImageFromCurrentImageContext()
            view.contentMode = .scaleAspectFill
            view.layer.cornerRadius = (pinImage?.size.width)! / 2
            view.clipsToBounds = true
            view.image = pinImage
            
            
            return view

        }
        return nil
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
