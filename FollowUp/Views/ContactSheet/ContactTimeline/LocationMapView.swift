//
//  LocationMapView.swift
//  FollowUp
//
//  Created by GPT on 13/08/2025.
//

import SwiftUI
import MapKit

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
        _region = State(initialValue: MKCoordinateRegion(center: center, span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01)))
    }

    var body: some View {
        NavigationView {
            Map(coordinateRegion: $region, annotationItems: [PinItem(coordinate: .init(latitude: latitude, longitude: longitude))]) { item in
                MapAnnotation(coordinate: item.coordinate) {
                    VStack(spacing: 6) {
                        if let address, !address.isEmpty {
                            Text(address)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.ultraThinMaterial)
                                .cornerRadius(8)
                        }
                        Button(action: openInMaps) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.red)
                                .shadow(radius: 2)
                        }
                        .accessibilityLabel("Open in Maps")
                    }
                }
            }
            .navigationTitle(address ?? "Met here")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Directions") { openInMaps() }
                }
            }
        }
    }

    private func openInMaps() {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let placemark = MKPlacemark(coordinate: coordinate)
        let item = MKMapItem(placemark: placemark)
        item.name = address ?? "Met here"
        MKMapItem.openMaps(with: [item], launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
}

private struct PinItem: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}



