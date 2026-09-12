//
//  StreakKeeperApp.swift
//  StreakKeeper
//

import SwiftUI
import SwiftData

@main
struct StreakKeeperApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([Habit.self, HabitLog.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    init() {
        NotificationManager.shared.requestAuthorization()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
