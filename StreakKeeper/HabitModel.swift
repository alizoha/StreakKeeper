//
//  HabitModel.swift
//  StreakKeeper
//
//  SwiftData models: Habit + HabitLog
//

import Foundation
import SwiftData

@Model
final class Habit {
    var id: UUID
    var name: String
    var iconName: String       // SF Symbol name
    var colorHex: String       // hex string, e.g. "FF6B6B"
    var createdDate: Date
    var isReminderOn: Bool
    var reminderTime: Date?    // only the time-of-day component matters

    @Relationship(deleteRule: .cascade, inverse: \HabitLog.habit)
    var logs: [HabitLog] = []

    init(
        name: String,
        iconName: String = "flame.fill",
        colorHex: String = "FF6B6B",
        isReminderOn: Bool = false,
        reminderTime: Date? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.iconName = iconName
        self.colorHex = colorHex
        self.createdDate = Date()
        self.isReminderOn = isReminderOn
        self.reminderTime = reminderTime
    }

    // MARK: - Derived stats

    /// Set of normalized (start-of-day) dates this habit was completed.
    var completedDaySet: Set<Date> {
        Set(logs.map { Calendar.current.startOfDay(for: $0.date) })
    }

    var isCompletedToday: Bool {
        completedDaySet.contains(Calendar.current.startOfDay(for: Date()))
    }

    /// Current streak counting backward from today (or yesterday if today isn't logged yet).
    var currentStreak: Int {
        let cal = Calendar.current
        let days = completedDaySet
        guard !days.isEmpty else { return 0 }

        var streak = 0
        var cursor = cal.startOfDay(for: Date())

        // If today isn't done yet, streak can still be "alive" through yesterday.
        if !days.contains(cursor) {
            cursor = cal.date(byAdding: .day, value: -1, to: cursor)!
        }

        while days.contains(cursor) {
            streak += 1
            cursor = cal.date(byAdding: .day, value: -1, to: cursor)!
        }
        return streak
    }

    /// Longest streak ever achieved.
    var longestStreak: Int {
        let cal = Calendar.current
        let sorted = completedDaySet.sorted()
        guard !sorted.isEmpty else { return 0 }

        var longest = 1
        var current = 1

        for i in 1..<sorted.count {
            let prev = sorted[i - 1]
            let curr = sorted[i]
            if let next = cal.date(byAdding: .day, value: 1, to: prev), next == curr {
                current += 1
                longest = max(longest, current)
            } else {
                current = 1
            }
        }
        return sorted.isEmpty ? 0 : longest
    }

    var totalCompletions: Int { logs.count }

    /// Completion rate over the last N days (0...1).
    func completionRate(lastDays: Int) -> Double {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let days = completedDaySet
        var completed = 0
        for offset in 0..<lastDays {
            if let day = cal.date(byAdding: .day, value: -offset, to: today), days.contains(day) {
                completed += 1
            }
        }
        return Double(completed) / Double(lastDays)
    }
}

@Model
final class HabitLog {
    var id: UUID
    var date: Date   // normalized to start of day
    var habit: Habit?

    init(date: Date = Date(), habit: Habit? = nil) {
        self.id = UUID()
        self.date = Calendar.current.startOfDay(for: date)
        self.habit = habit
    }
}
