//
//  LocationLabel.swift
//  FollowUp
//
//  Created by Aaron Baw on 13/08/2025.
//

import SwiftUI
import CoreLocation
import Contacts

struct LocationLabel: View {
    let location: LocationSample
    
    @State private var locationAddress: String?
    
    var addressString: String {
        locationAddress ?? "Loading Location..."
    }
    
    var body: some View {
        Button(action: {
            
        }, label: {
                Label(title: {
                    Text(addressString)
                        .multilineTextAlignment(.center)
                }, icon: { Image(icon: .locationArrow) })
        })
        .font(.footnote)
        .foregroundStyle(.blue)
        .onAppear { reverseGeocodeIfNeeded() }

    }
    
    func conciseAddress(from placemark: CLPlacemark) -> String {
        let streetParts = [placemark.subThoroughfare, placemark.thoroughfare]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        let street = streetParts.joined(separator: " ")
        let city = (placemark.locality ?? placemark.subLocality)?.trimmingCharacters(in: .whitespacesAndNewlines)
        let country = placemark.country?.trimmingCharacters(in: .whitespacesAndNewlines)
        return [street, city, country]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
    }

    func reverseGeocodeIfNeeded() {
        guard locationAddress == nil
        else { return }

        let location = CLLocation(latitude: location.latitude, longitude: location.longitude)
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, _ in
            guard let firstPlacemark = placemarks?.first else { return }
            self.locationAddress = conciseAddress(from: firstPlacemark)
        }
    }
}
