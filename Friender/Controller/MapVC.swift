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
    
    var locationManager = CLLocationManager()
    let authorizationStatus = CLLocationManager.authorizationStatus()
    var regionRadius: Double = 1000
    var mapHasCenteredOnce = false
    var userLocation = CLLocationCoordinate2D()
    
    
    var geoFire: GeoFire!
    var geofireRef: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        mapView.userTrackingMode = MKUserTrackingMode.follow
        geofireRef = Database.database().reference()
        geoFire = GeoFire(firebaseRef: geofireRef)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        locationAuthStatus()
    }
    
    func prepareLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locationManager.location?.coordinate {
            userLocation = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            let region = MKCoordinateRegion(center: userLocation, span: MKCoordinateSpan(latitudeDelta: regionRadius * 2, longitudeDelta: regionRadius * 2))
            
            mapView.setRegion(region, animated: true)
            
            mapView.removeAnnotations(mapView.annotations)
            
            let anno = MKPointAnnotation()
            anno.coordinate = userLocation
            anno.title = "thisLocation"
            
            mapView.addAnnotation(anno)
        }
        
    }
    
    func locationAuthStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            mapView.showsUserLocation = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func centerMapOnLocation(_ location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2, regionRadius * 2)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
     
    }
    
    
    @IBAction func addEventBtnWasPressed(_ sender: Any) {
        
       
    }
    
    @IBAction func centerMapBtnWasPressed(_ sender: Any) {
       

}




}
