//
//  Location.swift
//  SkyBlueWX
//
//  Created by Daniel Sanchez on 1/26/23.
//

import Foundation
import CoreLocation

final class LocationManager: NSObject, ObservableObject {
    @Published var location: CLLocation?
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters // Position only needs to be +/- 100m
        locationManager.distanceFilter = CLLocationDistance(1000) // Do not trigger updates until user has moved at least 1km from last position.
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
    }
}

// Need to annotate with comments for my own reference.
extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {return}
        DispatchQueue.main.async {
            self.location = location
            print("Location is\n\(self.location?.coordinate.latitude ?? 0)\n\(self.location?.coordinate.longitude ?? 0)")
        }
        
    }
}
