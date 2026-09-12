//
//  ContentView.swift
//  StreakKeeper
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Habit.createdDate) private var habits: [Habit]

    @State private var showingAddHabit = false

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color(hex: "1A1A2E"), Color(hex: "16213E")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                if habits.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        VStack(spacing: 14) {
                            ForEach(habits) { habit in
                                NavigationLink(value: habit) {
                                    HabitRow(habit: habit, onToggle: { toggleToday(habit) })
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("StreakKeeper")
            .navigationDestination(for: Habit.self) { habit in
                HabitDetailView(habit: habit)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddHabit = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingAddHabit) {
                AddHabitView()
            }
        }
        .preferredColorScheme(.dark)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "flame.fill")
                .font(.system(size: 56))
                .foregroundStyle(.orange)
            Text("No habits yet")
                .font(.title3.bold())
                .foregroundStyle(.white)
            Text("Tap + to start your first streak")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))
        }
    }

    private func toggleToday(_ habit: Habit) {
        let today = Calendar.current.startOfDay(for: Date())
        if let existing = habit.logs.first(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
            context.delete(existing)
        } else {
            let log = HabitLog(date: today, habit: habit)
            context.insert(log)
        }
        try? context.save()
    }
}

private struct HabitRow: View {
    let habit: Habit
    let onToggle: () -> Void

    private var color: Color { Color(hex: habit.colorHex) }

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: habit.iconName)
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 46, height: 46)
                .background(color.gradient, in: RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                Text(habit.name)
                    .font(.headline)
                    .foregroundStyle(.white)
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .font(.caption)
                        .foregroundStyle(.orange)
                    Text("\(habit.currentStreak) day streak")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                }
            }

            Spacer()

            Button(action: onToggle) {
                Image(systemName: habit.isCompletedToday ? "checkmark.circle.fill" : "circle")
                    .font(.title)
                    .foregroundStyle(habit.isCompletedToday ? color : .white.opacity(0.3))
            }
        }
        .padding()
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Habit.self, HabitLog.self], inMemory: true)
}
