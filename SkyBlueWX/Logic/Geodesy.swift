//
//  Geodesy.swift
//  SkyBlueWX
//
//  Created by Daniel Sanchez on 1/29/23.
//

import Foundation

/// This part's not going in for now...
/*
 func karneyInverse(_ p1: CLLocation, _ p2: CLLocation) -> GeodesicLine? {
 let lat1 = p1.coordinate.latitude
 let lon1 = p1.coordinate.longitude
 let lat2 = p2.coordinate.latitude
 let lon2 = p2.coordinate.longitude
 return karneyInverse(lat1: lat1, lon1: lon1, lat2: lat2, lon2: lon2)
 }
 
 class GeoMath {
 /// Creating a limited translation of Karney's Algorithms for Geodesics (geographiclib) for some required functionality
 static func errorFreeSum(_ u: Double, _ v: Double) -> (Double, Double) {
 /// Error free transformation of a sum.
 let s = u + v
 var up = s - v
 var vpp = s - up
 up -= u
 vpp -= v
 let t = s == 0.0 ? s : 0.0 - (up + vpp)
 return (s, t)
 }
 
 static func angularDifference(_ x: Double, _ y: Double) -> (Double, Double) {
 var (d, t) = GeoMath.errorFreeSum(-x.remainder(dividingBy: 360.0), y.remainder(dividingBy: 360.0))
 (d, t) = GeoMath.errorFreeSum(d.remainder(dividingBy: 360), t)
 if d == 0 || abs(d) == 180 {
 d = copysign(d, t == 0 ? y - x : -t)
 }
 return (d, t)
 }
 }
 
 func karneyInverse(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> GeodesicLine? {
 guard abs(lat1) <= 90 && abs(lon1) <= 180 else {return nil}
 guard abs(lat2) <= 90 && abs(lon2) <= 180 else {return nil}
 // Compute
 return GeodesicLine()
 }
 */
