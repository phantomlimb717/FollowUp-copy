//
//  LocationSample.swift
//  FollowUp
//
//  Created by Aaron Baw on 13/08/2025.
//

import CoreLocation
import Foundation
import RealmSwift

class LocationSample: Object, Identifiable {
    @Persisted(primaryKey: true) var id: String
    @Persisted var time: Date
    @Persisted var latitude: Double
    @Persisted var longitude: Double
    @Persisted var horizontalAccuracy: Double
    @Persisted var altitude: Double?
    @Persisted var verticalAccuracy: Double?
    
    // This property is not stored on the object but gives a backlink to all the timeline items that hold a link to this object.
    // Useful in case we need to remove location samples.
    @Persisted(originProperty: "location")
    var timelineItems: LinkingObjects<TimelineItem>

    convenience init(time: Date, latitude: Double, longitude: Double, horizontalAccuracy: Double, altitude: Double? = nil, verticalAccuracy: Double? = nil) {
        self.init()
        self.id = UUID().uuidString
        self.time = time
        self.latitude = latitude
        self.longitude = longitude
        self.horizontalAccuracy = horizontalAccuracy
        self.altitude = altitude
        self.verticalAccuracy = verticalAccuracy
    }
}

// MARK: - Extensions
extension LocationSample {
    convenience init(_ location: CLLocation) {
        self.init(
            time: location.timestamp,
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            horizontalAccuracy: location.horizontalAccuracy,
            altitude: location.verticalAccuracy >= 0 ? location.altitude : nil,
            verticalAccuracy: location.verticalAccuracy >= 0 ? location.verticalAccuracy : nil
        )
    }
}


extension CLLocation {
    var locationSample: LocationSample {
        .init(self)
    }
}
