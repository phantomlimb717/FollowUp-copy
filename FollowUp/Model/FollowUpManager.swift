//
//  FollowUpManager.swift
//  FollowUp
//
//  Created by Aaron Baw on 30/12/2021.
//

import BackgroundTasks
import Combine
import Foundation
import RealmSwift

final class FollowUpManager: ObservableObject {

    // MARK: - Private Stored Properties
    
    var realm: Realm?

    // First, we check to see if a follow up store exists in our realm.
    // If one doesn't exist, then we create one and add it to the realm.
    // If a follow up store has been passed as an argument, than this supercedes any store that we find in the realm.
    var store: FollowUpStore
    
    /// Error to be displayed to the user.
    @Published var error: FollowUpError?

    var contactsInteractor: ContactsInteracting
    private var subscriptions: Set<AnyCancellable> = .init()
    var notificationManager: NotificationManaging
    var interactionManager: InteractionManager

    private var locationManager: LocationManaging?
    
    // MARK: - Initialization
    init(
        contactsInteractor: ContactsInteracting? = nil,
        notificationManager: NotificationManaging = NotificationManager(),
        store: FollowUpStore? = nil,
        realmName: String = "followUpStore"
    ) {
        // The Schema (and Realm object) needs to be initialised first, as this is referenced in order to fetch any existing FollowUpStores from the Realm DB.
        let realm = Self.initializeRealm()
        let contactsInteractor = contactsInteractor ?? ContactsInteractor(realm: realm)
        self.realm = realm
        self.contactsInteractor = contactsInteractor
        // First, we check to see if a follow up store exists in our realm.
        // If one doesn't exist, then we create one and add it to the realm.
        // If a follow up store has been passed as an argument, than this supercedes any store that we find in the realm.
        self.store = store ?? FollowUpStore(realm: realm)
        self.interactionManager = InteractionManager(contactsInteractor: contactsInteractor)

        self.notificationManager = notificationManager
        self.subscribeForNewContacts()
        self.objectWillChange.send()
        
        // Initialize LocationManager and start monitoring
        self.locationManager = LocationManager(followUpManager: self)
        self.locationManager?.startMonitoring()
        
    }

    // MARK: - Methods
    private func subscribeForNewContacts() {
        self.contactsInteractor
            .contactsPublisher
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        return
                    case let .failure(error):
                        self.error = error
                    }
                },
                receiveValue: { contactSignal in
                    switch contactSignal {
                    case let .overwrite(newContacts):
                        self.store.updateWithFetchedContacts(newContacts)
                    case let .updateAndMerge(contact):
                        self.store.updateAndMerge(contact: contact)
                    }
                    self.linkContactLocationsInBackground()
                    self.linkTimelineLocationsInBackground()
            })
            .store(in: &self.subscriptions)
    }
    
    // MARK: - Realm Configuration
    static func initializeRealm(name: String = "followUpRealm") -> Realm? {
        // Get the document directory and create a file with the passed name
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let realmFileURL = documentDirectory?.appendingPathComponent("\(name).realm")
        let config = Realm.Configuration(
            fileURL: realmFileURL,
            schemaVersion: 12,
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 2 {
                    Log.info("Running migration to schema v2, adding contactListGrouping.")
                    migration.enumerateObjects(ofType: FollowUpSettings.className()) { oldObject, newObject in
                        newObject?["contactListGrouping"] = FollowUpSettings.ContactListGrouping.dayMonthYear.rawValue
                    }
                    Log.info("Migration complete.")
                }
                
                if oldSchemaVersion < 4 {
                    Log.info("Running migration to schema v4. Adding 'tags' property.")
                    migration.enumerateObjects(ofType: Contact.className()) { oldObject, newObject in
                        newObject?["tags"] = RealmSwift.List<Tag>()
                    }
                }

                if oldSchemaVersion < 5 {
                    Log.info("Running migration to schema V5.")
                    migration.enumerateObjects(ofType: FollowUpSettings.className(), { oldObject, newObject in
                        newObject?["followUpRemindersActive"] = false
                    })
                    Log.info("Migration complete.")
                }
                
                if oldSchemaVersion < 6 {
                    Log.info("Running migration to schema v6. Adding 'followUpFrequency' property.")
                    migration.enumerateObjects(ofType: Contact.className(), {oldObject, newObject in
                        newObject?["followUpFrequency"] = FollowUpFrequency.daily
                    })
                }
                
                if oldSchemaVersion < 7 {
                    Log.info("Running migration to schema v7. Adding 'timelineItems' property.")
                    migration.enumerateObjects(ofType: Contact.className(), { oldObject, newObject in
                        newObject?["timelineItems"] = RealmSwift.List<TimelineItem>()
                    })
                    Log.info("Migration Complete")
                }
                
                if oldSchemaVersion < 8 {
                    Log.info("Running migration to schema v8. Adding primary key to 'TimelineItem'.")
                    migration.enumerateObjects(ofType: TimelineItem.className(), { oldObject, newObject in
                        newObject?["id"] = UUID().uuidString
                    })
                }
                
                if oldSchemaVersion < 9 {
                    Log.info("Running migration to schema v9. Adding location to 'TimelineItem'.")
                    migration.enumerateObjects(ofType: TimelineItem.className(), { _, newObject in
                        newObject?["location"] = nil
                    })
                }
                
                if oldSchemaVersion < 10 {
                    Log.info("Running migration to schema v10. Adding location to 'Contact'.")
                    migration.enumerateObjects(ofType: Contact.className(), { _, newObject in
                        newObject?["firstAddedLocation"] = nil
                    })
                }
                
                if oldSchemaVersion < 12 {
                    Log.info("Running migration to schema v12. Removing 'time' property from LocationSample and adding 'source', 'arrivalDate' and 'departureDate'.")
                    migration.enumerateObjects(ofType: LocationSample.className()) { oldObject, newObject in
                        // Remove the 'time' property if it exists
                        // Realm automatically drops properties that are no longer in the model, so no action needed
                        newObject?["arrivalDate"] = oldObject?["time"]
                        newObject?["departureDate"] = nil
                        newObject?["source"] = SampleSource.location
                    }
                }
                
            }
        )
        
        // We set the default configuration so that we can open up multiple Realm instances with the same configuration.
        Realm.Configuration.defaultConfiguration = config
        
        do {
            return try Realm()
        } catch {
            Log.error("Could not open realm: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Location Linking
    private func linkLocationsToObjects<T: Object & LocationLinkable>(
        objects: Results<T>,
        locationSamples: Results<LocationSample>,
        getObjectDate: @escaping (T) -> Date,
        setObjectLocation: @escaping (T, LocationSample) -> Void,
        threshold: TimeInterval
    ) {
        for object in objects {
            let objectDate = getObjectDate(object)
            // 1. Try to find a visit sample where the object's date falls within the visit window
            if let visitSample = locationSamples.first(where: { sample in
                sample.source == .visit &&
                sample.arrivalDate <= objectDate &&
                (sample.departureDate ?? sample.arrivalDate) >= objectDate
            }) {
                setObjectLocation(object, visitSample)
                continue
            }
            // 2. Fallback: find the closest non-visit sample (or any sample)
            let start = objectDate.addingTimeInterval(-threshold)
            let end = objectDate.addingTimeInterval(threshold)
            let candidates = locationSamples.filter("arrivalDate >= %@ AND arrivalDate <= %@", start, end)
            guard !candidates.isEmpty else { continue }
            let bestCandidate = candidates.min { first, second in
                let firstDistance = abs(first.arrivalDate.timeIntervalSince(objectDate))
                let secondDistance = abs(second.arrivalDate.timeIntervalSince(objectDate))
                if firstDistance == secondDistance {
                    return (first.horizontalAccuracy) < (second.horizontalAccuracy)
                }
                return firstDistance < secondDistance
            }
            if let bestCandidate {
                setObjectLocation(object, bestCandidate)
            }
        }
    }

    func linkContactLocationsInBackground(threshold: TimeInterval = 20 * 60) {
        DispatchQueue.global(qos: .utility).async {
            autoreleasepool {
                do {
                    let realm = try Realm()
                    let unlinkedContacts = realm.objects(Contact.self).filter("firstAddedLocation == nil")
                    guard !unlinkedContacts.isEmpty else { return }
                    let locationSamples = realm.objects(LocationSample.self)
                    try realm.write {
                        self.linkLocationsToObjects(
                            objects: unlinkedContacts,
                            locationSamples: locationSamples,
                            getObjectDate: { $0.createDate },
                            setObjectLocation: { contact, location in
                                contact.firstAddedLocation = location
                                
                                // NOTE: When the source type is "visit", we use the createDate of the contact, as we assume that the contact was created within the visitation period of the location sample. For a source of "location", we defer to the arrivalDate as an approximation.
                                contact.timelineItems.append(
                                    .event(
                                        type: .firstMet,
                                        time: location.source == .visit ? contact.createDate : location.arrivalDate,
                                        location: location
                                    )
                                )
                            },
                            threshold: threshold
                        )
                    }
                } catch {
                    Log.error("Failed to link contacts to location samples: \(error.localizedDescription)")
                }
            }
        }
    }

    func linkTimelineLocationsInBackground(threshold: TimeInterval = 20 * 60) {
        DispatchQueue.global(qos: .utility).async {
            autoreleasepool {
                do {
                    let realm = try Realm()
                    let unlinkedTimelineItems = realm.objects(TimelineItem.self).filter("location == nil")
                    guard !unlinkedTimelineItems.isEmpty else { return }
                    let locationSamples = realm.objects(LocationSample.self)
                    try realm.write {
                        self.linkLocationsToObjects(
                            objects: unlinkedTimelineItems,
                            locationSamples: locationSamples,
                            getObjectDate: { $0.time },
                            setObjectLocation: { item, location in
                                item.location = location
                            },
                            threshold: threshold
                        )
                    }
                } catch {
                    Log.error("Failed to link timeline items to location samples: \(error.localizedDescription)")
                }
            }
        }
    }
    
    
    /// Uses significant location updates to periodically check for new contacts and schedule reminders to follow up.
    func configureNotifications() {
        
            DispatchQueue.main.async {
                
                if self.store.settings.followUpRemindersActive {
                    
                    // Check if we have the right authorisation for notifications and local updates.
                    self.notificationManager.requestNotificationAuthorization()
                    self.locationManager?.requestAuthorisation()
                    
                                        
                    self.scheduleBackgroundTaskForConfiguringNotifications(
                        onDay: .now.setting(
                            .hour,
                            to: Constant.Notification.defaultNotificationTriggerHour
                        )?.setting(.minute, to: 0)?.setting(.second, to: 0)
                    )
                    
                }
            }
            
        
    }
    
    private func scheduleBackgroundTaskForConfiguringNotifications(onDay date: Date?) {
        let date = date ?? .now

        let backgroundTaskRequest = BGAppRefreshTaskRequest(identifier: Constant.Processing.followUpRemindersTaskIdentifier)
        
        // Schedule the background task 30 minutes before the notification should be sheduled to the user.
        let backgroundTaskDate = date
            .setting(.hour, to: Constant.Notification.defaultNotificationTriggerHour - 1)?
            .setting(.minute, to: 30)
        
        backgroundTaskRequest.earliestBeginDate = backgroundTaskDate
        
        // Schedule the task on a background queue as submission is a blocking procedure.
        DispatchQueue.global(qos: .background).async {
            do {
                try BGTaskScheduler.shared.submit(backgroundTaskRequest)
                Log.info("Scheduled notification configuration background task for \(backgroundTaskDate?.description ?? "unknown date")")
            } catch {
                Log.error("Could not submit background task to schedule notifications. \(error.localizedDescription)")
            }
        }
    }
    
    func calculateNewlyMetContactsAndScheduleFollowUpReminderNotification() {
        self.contactsInteractor.fetchRecentlyAddedContacts(completion: { newContacts in
            
            // Before scheduling a new notification, we must clear the last one.
            Log.info("Clearing previously scheduled notifications.")
            self.notificationManager.clearScheduledNotifications()
            
            Log.info("Detected \(newContacts.count) recently added contacts. Reporting attempting to schedule notification.")
            self.notificationManager.scheduleRecentlyAddedNamesNotification(
                forRecentlyAddedContacts: newContacts,
                withConfiguration:
                        .init(
                            trigger: .tomorrowAt(
                                hour: Constant.Notification.defaultNotificationTriggerHour,
                                minute: Constant.Notification.defaultNotificationTriggerMinute
                            )
                        )
                )
        })
        
//        self.store.numberOfContacts(.thatAreNew) { numberOfContacts in
//            guard let numberOfContacts = numberOfContacts else {
//                Log.error("Unable to determine number of contacts met within specified timeframe.")
//                return
//            }
//            Log.info("Detected \(numberOfContacts) met today. Reporting attempting to schedule notification.")
//            self.notificationManager.scheduleNotification(
//                forNumberOfAddedContacts: numberOfContacts,
//                withConfiguration: .init(trigger: .now)
//            )
//        }
    }
    
    /// Contains the logic associated with a request to sechedule notifications while the app is running in the background.
    public func handleScheduledNotificationsBackgroundTask(_ task: BGAppRefreshTask?) {
        
        Log.info("Executing background task: \(task?.description ?? "Unknown task")")
        
        task?.expirationHandler = {
            Log.error("Could not register notifications.")
        }
                 
         // Clear current notifications.
         self.notificationManager.clearScheduledNotifications()
         
         // Re-register notifications.
         self.calculateNewlyMetContactsAndScheduleFollowUpReminderNotification()
         
         // Schedule a background task for tomorrow, at the same time.
         self.scheduleBackgroundTaskForConfiguringNotifications(onDay: Date().adding(1, to: .day))
         
         task?.setTaskCompleted(success: true)
    }

}

//#if DEBUG
extension FollowUpManager {
    static func mocked(
        numberOfContacts: Int = 5,
        realmIdentifier: String = "PreviewRealm"
    ) -> FollowUpManager {
        let config = Realm.Configuration(inMemoryIdentifier: realmIdentifier)
        let realm = try! Realm(configuration: config)

        // Add mock contacts
        try! realm.write {
            for i in 0..<numberOfContacts {
                let contact = Contact()
                contact.id = "\(i)"
                contact.name = "Mock Contact \(i)"
                contact.note = "This is a mock contact."
                realm.add(contact)
            }
        }

        let store = FollowUpStore(realm: realm)
        let manager = FollowUpManager(store: store, realmName: realmIdentifier)
        manager.realm = realm // ensure realm is assigned

        return manager
    }
}
//#endif

// Add a protocol for objects that can be linked to a location
protocol LocationLinkable {
    var location: LocationSample? { get set }
}

extension TimelineItem: LocationLinkable {}
extension Contact: LocationLinkable {
    var location: LocationSample? {
        get { firstAddedLocation }
        set { firstAddedLocation = newValue }
    }
}
