//
//  StreakCalendarView.swift
//  StreakKeeper
//
//  A month-grid heatmap showing which days a habit was completed.
//

import SwiftUI

struct StreakCalendarView: View {
    let monthDate: Date
    let completedDays: Set<Date>
    let accentColor: Color

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)

    private var monthDays: [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: monthDate),
              let firstOfMonth = calendar.date(
                from: calendar.dateComponents([.year, .month], from: monthDate)
              ) else { return [] }

        let weekdayOfFirst = calendar.component(.weekday, from: firstOfMonth) // 1 = Sunday
        let leadingBlanks = weekdayOfFirst - 1

        var days: [Date?] = Array(repeating: nil, count: leadingBlanks)
        for dayOffset in 0..<range.count {
            if let date = calendar.date(byAdding: .day, value: dayOffset, to: firstOfMonth) {
                days.append(date)
            }
        }
        return days
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(monthDate.formatted(.dateTime.month(.wide).year()))
                .font(.subheadline.bold())
                .foregroundStyle(.secondary)

            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(Array(monthDays.enumerated()), id: \.offset) { _, day in
                    if let day {
                        let isDone = completedDays.contains(calendar.startOfDay(for: day))
                        let isToday = calendar.isDateInToday(day)
                        let isFuture = day > Date()

                        Text("\(calendar.component(.day, from: day))")
                            .font(.caption2.weight(.semibold))
                            .frame(width: 32, height: 32)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(isDone ? accentColor : Color.gray.opacity(isFuture ? 0.05 : 0.12))
                            )
                            .foregroundStyle(isDone ? .white : (isFuture ? .secondary.opacity(0.4) : .primary))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(isToday ? accentColor : .clear, lineWidth: 2)
                            )
                    } else {
                        Color.clear.frame(width: 32, height: 32)
                    }
                }
            }
        }
    }
}
