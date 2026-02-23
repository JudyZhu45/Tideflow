import SwiftUI

struct AddTaskView: View {
    @Binding var isPresented: Bool
    let peakHour: Double
    let existingTasks: [EnergyTask]
    let onAdd: (EnergyTask) -> Void
    @State private var taskName = ""
    @State private var selectedEnergy: EnergyLevel = .medium
    @State private var duration = 30
    @State private var selectedEmoji = "📝"
    @State private var isUrgent = false
    private let emojiOptions = ["📝","💻","📞","🏃","📚","🎯","☕","🎨","🧘","📊"]

    private var previewTask: EnergyTask {
        var t = EnergyTask(name: taskName, emoji: selectedEmoji, energyLevel: selectedEnergy, durationMinutes: duration, isUrgent: isUrgent)
        let r = EnergyScheduler.optimalHour(for: t, peakHour: peakHour, existingTasks: existingTasks)
        t.scheduledHour = r.hour; t.aiReason = r.reason; return t
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "0A0E27").ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 24) {
                        // Emoji picker
                        VStack(alignment: .leading, spacing: 8) {
                            sectionLabel("Icon")
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(emojiOptions, id: \.self) { e in
                                        Text(e).font(.system(size: 28)).padding(8)
                                            .background(selectedEmoji == e ? Color(hex: "00D4AA").opacity(0.3) : Color.white.opacity(0.05))
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                            .onTapGesture { selectedEmoji = e }
                                    }
                                }
                            }
                        }
                        VStack(alignment: .leading, spacing: 8) {
                            sectionLabel("Task Name")
                            TextField("Enter task name", text: $taskName)
                                .font(.system(.body, design: .rounded)).padding(12)
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                        }
                        VStack(alignment: .leading, spacing: 8) {
                            sectionLabel("Energy Level")
                            Picker("Energy", selection: $selectedEnergy) {
                                ForEach(EnergyLevel.allCases, id: \.self) { l in Text("\(l.emoji) \(l.rawValue)").tag(l) }
                            }.pickerStyle(.segmented)
                        }
                        VStack(alignment: .leading, spacing: 8) {
                            sectionLabel("Duration: \(duration) minutes")
                            Stepper("\(duration) min", value: $duration, in: 15...120, step: 15)
                                .font(.system(.body, design: .rounded)).padding(12)
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                        }
                        HStack {
                            sectionLabel("Urgent")
                            Spacer()
                            Toggle("", isOn: $isUrgent).labelsHidden().tint(Color(hex: "00D4AA"))
                        }
                        .padding(12)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                        if !taskName.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                sectionLabel("AI Suggestion")
                                HStack(spacing: 12) {
                                    Text(selectedEmoji).font(.title2)
                                    VStack(alignment: .leading) {
                                        Text(taskName).font(.system(.subheadline, design: .rounded, weight: .semibold)).foregroundColor(.white)
                                        Text("Suggested: \(previewTask.formattedTime)").font(.system(.caption, design: .rounded)).foregroundColor(Color(hex: "00D4AA"))
                                    }
                                }.padding(12).frame(maxWidth: .infinity, alignment: .leading)
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }.padding(24)
                }
            }
            .navigationTitle("Add Task").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }.foregroundColor(.white.opacity(0.7))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { onAdd(previewTask); isPresented = false }
                        .disabled(taskName.isEmpty)
                        .foregroundColor(taskName.isEmpty ? .white.opacity(0.3) : Color(hex: "00D4AA"))
                        .font(.system(.body, design: .rounded, weight: .bold))
                }
            }
        }
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text).font(.system(.subheadline, design: .rounded, weight: .medium)).foregroundColor(.white.opacity(0.6))
    }
}
