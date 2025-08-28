//
//  LocationMapView.swift
//  FollowUp
//
//  Created by Aaron Baw on 13/08/2025.
//

import SwiftUI
import CoreLocation
import MapKit

private struct MapPinItem: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let title: String?
}

struct LocationMapView: View {
    let latitude: Double
    let longitude: Double
    let address: String?

    @Environment(\.dismiss) private var dismiss
    @State private var region: MKCoordinateRegion

    init(latitude: Double, longitude: Double, address: String?) {
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
        let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        _region = State(initialValue: MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)))
    }

    var body: some View {
        NavigationView {
            Map(
                coordinateRegion: $region,
                annotationItems: [MapPinItem(coordinate: .init(latitude: latitude, longitude: longitude), title: address ?? "Met here")]
            ) { item in
                MapMarker(coordinate: item.coordinate)
            }
            .navigationTitle(address ?? "Met here")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}
