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
import Firebase
import FirebaseStorage

class MapVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var manager: CLLocationManager?
    var regionRadius: CLLocationDistance = 1000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager = CLLocationManager()
        manager?.delegate = self
        manager?.desiredAccuracy = kCLLocationAccuracyBest
        checkAuthorizationStatus()
        mapView.delegate = self
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

}
