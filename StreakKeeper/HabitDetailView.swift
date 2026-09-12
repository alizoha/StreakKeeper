//
//  HabitDetailView.swift
//  StreakKeeper
//

import SwiftUI
import SwiftData
import Charts

struct HabitDetailView: View {
    @Bindable var habit: Habit
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var showingDeleteConfirm = false

    private var color: Color { Color(hex: habit.colorHex) }

    private var last7DaysData: [(day: String, done: Int)] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let days = habit.completedDaySet
        return (0..<7).reversed().map { offset in
            let date = cal.date(byAdding: .day, value: -offset, to: today)!
            let label = date.formatted(.dateTime.weekday(.abbreviated))
            return (label, days.contains(date) ? 1 : 0)
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                header

                statsRow

                VStack(alignment: .leading, spacing: 12) {
                    Text("Last 7 Days")
                        .font(.headline)
                    Chart(last7DaysData, id: \.day) { item in
                        BarMark(
                            x: .value("Day", item.day),
                            y: .value("Done", item.done)
                        )
                        .foregroundStyle(color.gradient)
                        .cornerRadius(6)
                    }
                    .frame(height: 140)
                    .chartYAxis(.hidden)
                }
                .padding()
                .background(.gray.opacity(0.08), in: RoundedRectangle(cornerRadius: 16))

                VStack(alignment: .leading) {
                    StreakCalendarView(
                        monthDate: Date(),
                        completedDays: habit.completedDaySet,
                        accentColor: color
                    )
                }
                .padding()
                .background(.gray.opacity(0.08), in: RoundedRectangle(cornerRadius: 16))

                Button(role: .destructive) {
                    showingDeleteConfirm = true
                } label: {
                    Label("Delete Habit", systemImage: "trash")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.red)
            }
            .padding()
        }
        .navigationTitle(habit.name)
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            "Delete this habit and all its history?",
            isPresented: $showingDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                NotificationManager.shared.cancelReminder(for: habit)
                context.delete(habit)
                try? context.save()
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    private var header: some View {
        VStack(spacing: 10) {
            Image(systemName: habit.iconName)
                .font(.system(size: 40))
                .foregroundStyle(.white)
                .frame(width: 80, height: 80)
                .background(color.gradient, in: Circle())

            HStack(spacing: 6) {
                Image(systemName: "flame.fill").foregroundStyle(.orange)
                Text("\(habit.currentStreak) day streak")
                    .font(.title3.bold())
            }
        }
    }

    private var statsRow: some View {
        HStack(spacing: 12) {
            statCard(title: "Longest", value: "\(habit.longestStreak)")
            statCard(title: "Total", value: "\(habit.totalCompletions)")
            statCard(title: "30-day", value: "\(Int(habit.completionRate(lastDays: 30) * 100))%")
        }
    }

    private func statCard(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value).font(.title2.bold())
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(.gray.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
    }
}
