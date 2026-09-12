//
//  NotificationManager.swift
//  StreakKeeper
//
//  Wraps UNUserNotificationCenter for per-habit daily reminders.
//

import Foundation
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error {
                print("Notification auth error: \(error.localizedDescription)")
            }
        }
    }

    /// Schedules a repeating daily reminder for a habit at the given time-of-day.
    func scheduleReminder(for habit: Habit) {
        guard habit.isReminderOn, let time = habit.reminderTime else {
            cancelReminder(for: habit)
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "Time for: \(habit.name)"
        content.body = "Keep your \(habit.currentStreak)-day streak going 🔥"
        content.sound = .default

        var components = Calendar.current.dateComponents([.hour, .minute], from: time)
        components.second = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: habit.id.uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [habit.id.uuidString])
        UNUserNotificationCenter.current().add(request)
    }

    func cancelReminder(for habit: Habit) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [habit.id.uuidString])
    }
}
