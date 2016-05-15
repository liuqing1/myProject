//
// Created by Tuo on 12/23/15.
// Copyright (c) 2015 ReignDesign. All rights reserved.
//

import Foundation
import MapKit

class MapUtils {

    static func reverseGeocodeLocation(location: CLLocation, completion: (String) -> Void) {
        let geocoder:CLGeocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            if error != nil {
                print("Reverse geocoder failed with error: \(error!.localizedDescription)")
                completion("[\(location.coordinate.latitude), \(location.coordinate.longitude)]")
            }
            if let placemarks = placemarks where placemarks.count > 0 {
                let placemark = placemarks[0] 
                completion(formalizedPlace(placemark))
            } else {
                completion("[\(location.coordinate.latitude), \(location.coordinate.longitude)]")
            }
        })
    }

    static func formalizedPlace(placemark: CLPlacemark) -> String {
        let joiner = ", "
        if let lines = placemark.addressDictionary!["FormattedAddressLines"] as? [String] {
            return lines.joinWithSeparator(joiner)
        }else{
            return ""
        }
    }

    static func mapRectForPoints(locations: [CLLocation!]) -> MKCoordinateRegion {
        var r = MKMapRectNull
        for location in locations {
            let p = MKMapPointForCoordinate(location.coordinate)
            r = MKMapRectUnion(r, MKMapRectMake(p.x, p.y, 0, 0))
        }
        return MKCoordinateRegionForMapRect(r)
    }

}
