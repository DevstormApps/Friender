//
//  MapVC.swift
//  Friender
//
//  Created by mac on 3/8/18.
//  Copyright © 2018 storm. All rights reserved.
//

import UIKit
import GoogleMaps

class MapVC: UIViewController {
    
    private let locationManager = CLLocationManager()


    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var mapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()

    }
   
    private func reverseGeocodeCoordinate(_ coordinate: CLLocationCoordinate2D) {
        
        // 1
        let geocoder = GMSGeocoder()
        
        // 2
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            guard let address = response?.firstResult(), let lines = address.lines else {
                return
            }
            
            // 3
            self.addressLabel.text = lines.joined(separator: "\n")
            
            let labelHeight = self.addressLabel.intrinsicContentSize.height
            self.mapView.padding = UIEdgeInsets(top: self.view.safeAreaInsets.top, left: 0,
                                                bottom: labelHeight, right: 0)
            
            // 4
                  }
    }
    
    @IBAction func onBtnWasPressed(_ sender: Any) {
    }
    

}

// MARK: - CLLocationManagerDelegate
//1
extension MapVC: CLLocationManagerDelegate {
    // 2
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // 3
        guard status == .authorizedWhenInUse else {
            return
        }
        // 4
        locationManager.startUpdatingLocation()
        
        //5
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
    }
    
    // 6
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        
        // 7
        mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
        
        // 8
        locationManager.stopUpdatingLocation()
    }
}

// MARK: - GMSMapViewDelegate
extension MapVC: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        reverseGeocodeCoordinate(position.target)
    }
    
}
