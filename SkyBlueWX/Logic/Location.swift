//
//  Location.swift
//  SkyBlueWX
//
//  Created by Daniel Sanchez on 1/26/23.
//

import Foundation
import CoreLocation

struct GeodesicLine {
    init() {
    }
}

final class LocationManager: NSObject, ObservableObject {
    /// Published wrappers are contained in classes only:
    /// Within SwiftUI, if there are views that reference "published" variables,
    /// a refresh of those views' body methods will be called at that time.
    ///
    @Published var location: CLLocation?
    private let locationManager = CLLocationManager()
    override init() {
        super.init()
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters // Position only needs to be +/- 100m
        // Do not trigger updates until user has moved at least 1km from last position.
        locationManager.distanceFilter = CLLocationDistance(1000)
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
            print(
                "Location is\n\(self.location?.coordinate.latitude ?? 0)\n\(self.location?.coordinate.longitude ?? 0)")
        }
    }
}
