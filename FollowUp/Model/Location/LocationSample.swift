//
//  LocationSample.swift
//  FollowUp
//
//  Created by Aaron Baw on 13/08/2025.
//

import CoreLocation
import Foundation
import RealmSwift

enum SampleSource: String, PersistableEnum {
    
    /// Samples taken via CLLocation (regular location updates or significant location updates)
    case location
    
    /// Samples taken via CLVisits (describes periods of time users spend in specific locations)
    case visit
}

class LocationSample: Object, Identifiable {
    @Persisted(primaryKey: true) var id: String
    @Persisted var arrivalDate: Date
    @Persisted var departureDate: Date?
    @Persisted var latitude: Double
    @Persisted var longitude: Double
    @Persisted var horizontalAccuracy: Double
    @Persisted var altitude: Double?
    @Persisted var verticalAccuracy: Double?
    @Persisted var source: SampleSource
    
    // This property is not stored on the object but gives a backlink to all the timeline items that hold a link to this object.
    // Useful in case we need to remove location samples.
    @Persisted(originProperty: "location")
    var timelineItems: LinkingObjects<TimelineItem>

    // Computed property for compatibility
    var time: Date? { arrivalDate }

    // For non-visit samples, arrivalDate and departureDate are set to the same value
    convenience init(
        arrivalDate: Date,
        latitude: Double,
        longitude: Double,
        horizontalAccuracy: Double,
        altitude: Double? = nil,
        verticalAccuracy: Double? = nil,
        source: SampleSource = .location
    ) {
        self.init()
        self.id = UUID().uuidString
        self.arrivalDate = arrivalDate
        self.departureDate = arrivalDate
        self.latitude = latitude
        self.longitude = longitude
        self.horizontalAccuracy = horizontalAccuracy
        self.altitude = altitude
        self.verticalAccuracy = verticalAccuracy
        self.source = source
    }

    // For visit samples
    convenience init(
        arrivalDate: Date,
        departureDate: Date,
        latitude: Double,
        longitude: Double,
        horizontalAccuracy: Double,
        altitude: Double? = nil,
        verticalAccuracy: Double? = nil,
        source: SampleSource = .visit
    ) {
        self.init()
        self.id = UUID().uuidString
        self.arrivalDate = arrivalDate
        self.departureDate = departureDate
        self.latitude = latitude
        self.longitude = longitude
        self.horizontalAccuracy = horizontalAccuracy
        self.altitude = altitude
        self.verticalAccuracy = verticalAccuracy
        self.source = source
    }
}

// MARK: - Extensions
extension LocationSample {
    convenience init(_ location: CLLocation) {
        self.init(
            arrivalDate: location.timestamp,
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            horizontalAccuracy: location.horizontalAccuracy,
            altitude: location.verticalAccuracy >= 0 ? location.altitude : nil,
            verticalAccuracy: location.verticalAccuracy >= 0 ? location.verticalAccuracy : nil,
            source: .location
        )
    }
    
    convenience init(_ visit: CLVisit) {
        self.init(
            arrivalDate: visit.arrivalDate,
            departureDate: visit.departureDate,
            latitude: visit.coordinate.latitude,
            longitude: visit.coordinate.longitude,
            horizontalAccuracy: visit.horizontalAccuracy,
            altitude: nil,
            verticalAccuracy: nil,
            source: .visit
        )
    }
}


extension CLLocation {
    var locationSample: LocationSample {
        .init(self)
    }
}
