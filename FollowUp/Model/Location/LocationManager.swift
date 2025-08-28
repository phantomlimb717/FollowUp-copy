//
//  LocationManager.swift
//  FollowUp
//
//  Created by Aaron Baw on 04/10/2024.
//

import Foundation
import CoreLocation
import Combine

protocol LocationManaging: AnyObject {
    func requestAuthorisation()
    func startMonitoring()
    func stopMonitoring()
}

class LocationManager: NSObject, LocationManaging, CLLocationManagerDelegate {

    // MARK: - Properties
    private let locationManager = CLLocationManager()
    private var followUpManager: FollowUpManager
    private var cancellables = Set<AnyCancellable>()
    
    public var authorisationStatus: CLAuthorizationStatus = .notDetermined
    
    // MARK: - Computed Properties
    var hasSufficientAuthorisation: Bool {
        self.locationManager.authorizationStatus == .authorizedAlways
    }

    // MARK: - Initialization
    init(followUpManager: FollowUpManager) {
        self.followUpManager = followUpManager
        super.init()
        self.locationManager.delegate = self
        self.locationManager.pausesLocationUpdatesAutomatically = false
        self.locationManager.allowsBackgroundLocationUpdates = true
        // Seed with current status so we don't sit at .notDetermined until delegate fires
        self.authorisationStatus = self.locationManager.authorizationStatus
    }
    
    // MARK: - Authorisation
    func requestAuthorisation() {
        // Route through unified handler to avoid duplicated logic
        self.handleAuthorizationChange(self.locationManager.authorizationStatus)
    }

    // MARK: - Start/Stop Monitoring
    func startMonitoring() {
        guard self.hasSufficientAuthorisation else {
            self.requestAuthorisation()
            return
        }
        
        if CLLocationManager.significantLocationChangeMonitoringAvailable() {
            self.locationManager.startMonitoringSignificantLocationChanges()
            Log.info("Started significant location monitoring.")
        } else {
            // Handle if significant location change monitoring is unavailable
            Log.error("Significant location change monitoring is unavailable.")
        }
        
        self.locationManager.startMonitoringVisits()
        Log.info("Started visit monitoring.")

    }

    func stopMonitoring() {
        self.locationManager.stopMonitoringSignificantLocationChanges()
    }

    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // Legacy callback – forward to unified handler
        self.handleAuthorizationChange(manager.authorizationStatus)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // iOS 14+
        self.handleAuthorizationChange(manager.authorizationStatus)
    }

    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        Log.info("Visit detected at: \(visit.coordinate) arrival: \(visit.arrivalDate) departure: \(visit.departureDate)")
        let sample = LocationSample(visit)
        self.record(samples: [sample])
    }

    private func handleAuthorizationChange(_ status: CLAuthorizationStatus) {
        self.authorisationStatus = status
        switch status {
        case .authorizedAlways:
            Log.info("Location authorized: Always.")
            self.startMonitoring()
        case .authorizedWhenInUse:
            Log.info("Location authorized: When In Use. Requesting Always.")
            self.locationManager.requestAlwaysAuthorization()
        case .denied, .restricted:
            Log.error("Location access denied/restricted.")
        case .notDetermined:
            Log.info("Location authorization not determined. Requesting When-In-Use.")
            self.locationManager.requestWhenInUseAuthorization()
        @unknown default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Compute the number of new contacts when significant location changes occur
        Log.info("Significant location change occured. \(locations.first?.coordinate ?? .init()) at \(locations.first?.timestamp)")
        
        self.record(locations: locations)
        
        // Current notification system uses significant location updates to re-calculate local notification reminders
        if self.followUpManager.store.settings.followUpRemindersActive {
            self.computeContactsAndScheduleNotification()
        }
    }
    
    private func record(locations: [CLLocation]) {
        guard let realm = followUpManager.realm else {
            Log.error("Could not record \(locations.count) locations as FollowUpManager's realm is unavailable.")
            return
        }
        
        let samples = locations.map(\.locationSample)
        
        Log.info("Recording \(samples.count) location samples. ")
        
        realm.writeAsync {
            realm.add(samples, update: .modified)
        }
    }
    
    private func record(samples: [LocationSample]) {
        guard let realm = followUpManager.realm else {
            Log.error("Could not record \(samples.count) location samples as FollowUpManager's realm is unavailable.")
            return
        }
        Log.info("Recording \(samples.count) location samples. ")
        realm.writeAsync {
            realm.add(samples, update: .modified)
        }
    }

    // MARK: - Compute New Contacts
    private func computeContactsAndScheduleNotification() {
        self.followUpManager.calculateNewlyMetContactsAndScheduleFollowUpReminderNotification()
    }
}
