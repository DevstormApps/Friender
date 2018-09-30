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

class MapVC: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, UISearchDisplayDelegate {
    
    @IBOutlet weak var mapView: GMSMapView!
    
    var manager: CLLocationManager?
    var regionRadius: CLLocationDistance = 1000
    let user = Auth.auth().currentUser
    var storageRef: StorageReference!
    var storageDownloadTask: StorageDownloadTask!
    var eventCoords: CLLocationCoordinate2D?
    
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
   

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareSearchBar()
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
        centerOnMap()
        loadAnnotation()
    }
    
    func checkAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedAlways  {
            manager?.startUpdatingLocation()
        } else {
            manager?.requestAlwaysAuthorization()
        }
    }
    
    func centerOnMap() {
        mapView.camera = GMSCameraPosition.camera(withTarget: (manager?.location?.coordinate)!, zoom: 14.0) // show your device location on map

    }
    
   
    func prepareSearchBar() {
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        
        // Put the search bar in the navigation bar.
        searchController?.searchBar.sizeToFit()
        navigationItem.titleView = searchController?.searchBar
        
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        definesPresentationContext = true
        
        // Prevent the navigation bar from being hidden when searching.
        searchController?.hidesNavigationBarDuringPresentation = false
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

// Handle the user's selection.
extension MapVC: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false
        // Do something with the selected place.
        print("Place name: \(place.name)")
        print("Place address: \(place.formattedAddress)")
        print("Place attributions: \(place.attributions)")
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: Error){
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
