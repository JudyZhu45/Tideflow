import SwiftUI

struct CompletedTasksView: View {
    @Binding var tasks: [EnergyTask]
    @Environment(\.dismiss) private var dismiss

    private var completedTasks: [EnergyTask] {
        tasks.filter(\.isCompleted)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "0A0E27").ignoresSafeArea()
                if completedTasks.isEmpty {
                    VStack(spacing: 12) {
                        Text("No completed tasks yet")
                            .font(.system(.headline, design: .rounded))
                            .foregroundColor(.white.opacity(0.5))
                        Text("Double-tap a task to complete it")
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(.white.opacity(0.3))
                    }
                } else {
                    List {
                        ForEach(completedTasks) { task in
                            HStack(spacing: 12) {
                                Text(task.emoji).font(.title3)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(task.name)
                                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                                        .foregroundColor(.white)
                                    Text(task.formattedTime)
                                        .font(.system(.caption, design: .rounded))
                                        .foregroundColor(.white.opacity(0.5))
                                }
                                Spacer()
                                Text(task.energyLevel.emoji).font(.caption)
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(Color(hex: "00D4AA"))
                            }
                            .listRowBackground(Color.white.opacity(0.05))
                        }
                        .onDelete { offsets in
                            let ids = offsets.map { completedTasks[$0].id }
                            tasks.removeAll { ids.contains($0.id) }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Completed")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundColor(Color(hex: "00D4AA"))
                        .font(.system(.body, design: .rounded, weight: .bold))
                }
            }
        }
    }
}

struct EnergyRatingSheet: View {
    let task: EnergyTask
    let onRate: (Double) -> Void
    @Environment(\.dismiss) private var dismiss

    private let options: [(emoji: String, label: String, value: Double)] = [
        ("😴", "Low", 0.3),
        ("😊", "Medium", 0.6),
        ("⚡", "High", 1.0)
    ]

    var body: some View {
        VStack(spacing: 20) {
            Text("How's your energy?")
                .font(.system(.headline, design: .rounded, weight: .bold))
                .foregroundColor(.white)
            Text("Rate your current energy level to personalize your curve")
                .font(.system(.caption, design: .rounded))
                .foregroundColor(.white.opacity(0.5))
                .multilineTextAlignment(.center)

            HStack(spacing: 16) {
                ForEach(options, id: \.label) { option in
                    Button {
                        onRate(option.value)
                        dismiss()
                    } label: {
                        VStack(spacing: 8) {
                            Text(option.emoji).font(.system(size: 36))
                            Text(option.label)
                                .font(.system(.caption, design: .rounded, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.1), lineWidth: 1))
                    }
                }
            }

            Button {
                onRate(0.6)
                dismiss()
            } label: {
                Text("Skip")
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.white.opacity(0.4))
            }
        }
        .padding(24)
        .background(Color(hex: "0A0E27").ignoresSafeArea())
    }
}
