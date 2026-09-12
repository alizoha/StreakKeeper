//
//  AddHabitView.swift
//  StreakKeeper
//

import SwiftUI
import SwiftData

struct AddHabitView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var selectedIcon = "flame.fill"
    @State private var selectedColorHex = Color.habitPalette[0]
    @State private var isReminderOn = false
    @State private var reminderTime = Date()

    private let icons = [
        "flame.fill", "book.fill", "drop.fill", "figure.run",
        "bed.double.fill", "leaf.fill", "dumbbell.fill", "pencil",
        "cup.and.saucer.fill", "moon.stars.fill", "heart.fill", "brain.head.profile"
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("Habit") {
                    TextField("e.g. Drink water", text: $name)
                }

                Section("Icon") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                        ForEach(icons, id: \.self) { icon in
                            Image(systemName: icon)
                                .font(.title2)
                                .frame(width: 40, height: 40)
                                .background(
                                    selectedIcon == icon ? Color(hex: selectedColorHex) : Color.gray.opacity(0.15),
                                    in: RoundedRectangle(cornerRadius: 10)
                                )
                                .foregroundStyle(selectedIcon == icon ? .white : .primary)
                                .onTapGesture { selectedIcon = icon }
                        }
                    }
                    .padding(.vertical, 6)
                }

                Section("Color") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                        ForEach(Color.habitPalette, id: \.self) { hex in
                            Circle()
                                .fill(Color(hex: hex))
                                .frame(width: 36, height: 36)
                                .overlay(
                                    Circle().stroke(.primary, lineWidth: selectedColorHex == hex ? 3 : 0)
                                )
                                .onTapGesture { selectedColorHex = hex }
                        }
                    }
                    .padding(.vertical, 6)
                }

                Section("Reminder") {
                    Toggle("Daily reminder", isOn: $isReminderOn.animation())
                    if isReminderOn {
                        DatePicker("Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                    }
                }
            }
            .navigationTitle("New Habit")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func save() {
        let habit = Habit(
            name: name.trimmingCharacters(in: .whitespaces),
            iconName: selectedIcon,
            colorHex: selectedColorHex,
            isReminderOn: isReminderOn,
            reminderTime: isReminderOn ? reminderTime : nil
        )
        context.insert(habit)
        try? context.save()

        if isReminderOn {
            NotificationManager.shared.scheduleReminder(for: habit)
        }
        dismiss()
    }
}

#Preview {
    AddHabitView()
        .modelContainer(for: [Habit.self, HabitLog.self], inMemory: true)
}
